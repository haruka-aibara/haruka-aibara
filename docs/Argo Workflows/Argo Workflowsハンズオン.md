# Argo Workflows ハンズオン（約50分）

## こういう場面で使う

「データを取ってきて → 加工して → 3種類の集計を並列で走らせて → 最後にまとめる」ような処理を Kubernetes 上で動かしたいとき、素朴にやると困る。

- Job を1個ずつ `kubectl apply` して、終わったのを目で確認して次を流すことになる
- 並列に走らせた処理が全部終わるのを待つ仕組みを自前で書くことになる
- どこで落ちたのか、どのステップを再実行すればいいのかが追いにくい

Argo Workflows は、この「ステップの順番・並列・受け渡し・リトライ」を YAML 1枚で宣言すると、各ステップを Pod として順に起動してくれる Kubernetes 上のワークフローエンジン。

同じ Argo でも **Argo CD は「Git の状態をクラスターに同期し続ける」もの**（[Argo CDとは](../Argo%20CD/Argo%20CDとは.md)）で、Argo Workflows は「処理を1回走らせて終わる」もの。GitHub Actions でも順番・並列は書けるが、ステップがクラスター内の Pod として動くので、クラスター内のデータやリソースに直接触る処理（バッチ・ML パイプライン・大量並列）で差が出る。

## 進め方

| # | 内容 | 目安 |
|---|---|---|
| 0 | クラスター作成・インストール | 10分 |
| 1 | Hello World と UI | 5分 |
| 2 | パラメータ | 5分 |
| 3 | steps（直列・並列） | 5分 |
| 4 | DAG と値の受け渡し | 10分 |
| 5 | リトライと条件分岐 | 5分 |
| 6 | WorkflowTemplate / CronWorkflow | 5分 |
| 7 | 片付け | 2分 |

前提：Docker が動くこと。`kind` と `kubectl` がなければ入れておく（[kind Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/)）。

作業用ディレクトリを作っておく。

```bash
mkdir argo-handson && cd argo-handson
```

---

## 0. クラスター作成とインストール（10分）

```bash
kind create cluster --name argo

# 最新リリースのタグを取得
ARGO_WORKFLOWS_VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-workflows/releases/latest | grep -m1 '"tag_name"' | cut -d'"' -f4)
echo $ARGO_WORKFLOWS_VERSION

kubectl create namespace argo
kubectl apply -n argo -f "https://github.com/argoproj/argo-workflows/releases/download/${ARGO_WORKFLOWS_VERSION}/quick-start-minimal.yaml"
kubectl -n argo wait --for=condition=Available deploy --all --timeout=180s
```

`quick-start-minimal.yaml` は学習用のマニフェスト（認証なしで UI に入れる設定になっている）。本番ではこれを使わない。

CLI も入れる（Linux の例。macOS は `darwin`、Apple Silicon は `darwin-arm64`）。

```bash
curl -sLO "https://github.com/argoproj/argo-workflows/releases/download/${ARGO_WORKFLOWS_VERSION}/argo-linux-amd64.gz"
gunzip argo-linux-amd64.gz
chmod +x argo-linux-amd64
sudo mv argo-linux-amd64 /usr/local/bin/argo
argo version
```

以降のコマンドで毎回 `-n argo` を付けるのが面倒なので、デフォルトの namespace を変えておく。

```bash
kubectl config set-context --current --namespace=argo
```

UI は別ターミナルで port-forward して開く。

```bash
kubectl -n argo port-forward svc/argo-server 2746:2746
```

ブラウザで `https://localhost:2746` を開く（自己署名証明書の警告は進んでよい）。

---

## 1. Hello World と UI（5分）

`hello.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hello-
spec:
  entrypoint: main
  templates:
    - name: main
      container:
        image: busybox
        command: [echo, "hello argo"]
```

```bash
argo submit hello.yaml --watch
argo list
argo logs @latest
```

覚えるのは2つだけ。

- **`templates` は「1ステップで何をするか」の定義**。`container` を書くとそれが Pod になる
- **`entrypoint` はどの template から始めるか**

UI の Workflows 画面に `hello-xxxxx` が出ているはず。クリックしてノード → LOGS でも同じログが見える。`kubectl get pods` すると、ステップごとに Pod が作られて Completed になっているのも確認できる。

---

## 2. パラメータ（5分）

実行ごとに値を変えたい場面。

`param.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: param-
spec:
  entrypoint: main
  arguments:
    parameters:
      - name: name
        value: world          # デフォルト値
  templates:
    - name: main
      inputs:
        parameters:
          - name: name
      container:
        image: busybox
        command: [echo, "hello {{inputs.parameters.name}}"]
```

```bash
argo submit param.yaml --watch
argo submit param.yaml -p name=argo --watch
argo logs @latest
```

`{{...}}` がテンプレート変数。ワークフロー全体の引数（`spec.arguments`）が、entrypoint の `inputs` に渡る。

---

## 3. steps：直列と並列（5分）

`steps` は「外側のリストが直列、内側のリストが並列」。

`steps.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: steps-
spec:
  entrypoint: main
  templates:
    - name: main
      steps:
        - - name: prepare           # 1段目
            template: say
            arguments: {parameters: [{name: msg, value: prepare}]}
        - - name: job-a             # 2段目（a と b は並列）
            template: say
            arguments: {parameters: [{name: msg, value: A}]}
          - name: job-b
            template: say
            arguments: {parameters: [{name: msg, value: B}]}
        - - name: finish            # 3段目
            template: say
            arguments: {parameters: [{name: msg, value: finish}]}

    - name: say
      inputs:
        parameters: [{name: msg}]
      container:
        image: busybox
        command: [sh, -c]
        args: ["echo {{inputs.parameters.msg}}; sleep 3"]
```

```bash
argo submit steps.yaml --watch
```

`--watch` の出力と UI のグラフで、`job-a` と `job-b` が同時に走り、両方終わってから `finish` が始まるのを確認する。`say` を1回定義して引数違いで使い回しているのがポイント。

---

## 4. DAG と値の受け渡し（10分）

steps は「段」でしか並びを表せない。「C は A だけ待てばいいのに B の終わりまで待たされる」を避けたいときは DAG で依存関係を直接書く。ついでに前のステップの出力を次に渡す。

`dag.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: dag-
spec:
  entrypoint: main
  templates:
    - name: main
      dag:
        tasks:
          - name: fetch
            template: gen-number
          - name: double
            dependencies: [fetch]
            template: calc
            arguments:
              parameters:
                - {name: expr, value: "{{tasks.fetch.outputs.result}} * 2"}
          - name: square
            dependencies: [fetch]
            template: calc
            arguments:
              parameters:
                - {name: expr, value: "{{tasks.fetch.outputs.result}} * {{tasks.fetch.outputs.result}}"}
          - name: report
            dependencies: [double, square]
            template: say
            arguments:
              parameters:
                - {name: msg, value: "double={{tasks.double.outputs.result}} square={{tasks.square.outputs.result}}"}

    - name: gen-number            # 標準出力がそのまま outputs.result になる
      script:
        image: python:3.12-alpine
        command: [python]
        source: |
          import random
          print(random.randint(1, 10))

    - name: calc
      inputs:
        parameters: [{name: expr}]
      script:
        image: busybox
        command: [sh]
        source: |
          echo $(( {{inputs.parameters.expr}} ))

    - name: say
      inputs:
        parameters: [{name: msg}]
      container:
        image: busybox
        command: [echo, "{{inputs.parameters.msg}}"]
```

```bash
argo submit dag.yaml --watch
argo logs @latest
```

- **`dependencies`** に書いたタスクが終わったら走る。`double` と `square` は `fetch` だけを待つので並列になる
- **`script` テンプレートの標準出力は `outputs.result`** で後続から参照できる。小さな値の受け渡しはこれで足りる（ファイルを渡したいときは artifact を使うが、保存先の設定が要るのでここでは扱わない）

UI のグラフが菱形（fetch → double/square → report）になっていることを確認する。

---

## 5. リトライと条件分岐（5分）

たまに落ちる処理をリトライさせ、結果によって次の処理を変える。

`retry.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: retry-
spec:
  entrypoint: main
  templates:
    - name: main
      steps:
        - - name: flaky
            template: flaky
        - - name: coin
            template: coin
        - - name: heads
            template: say
            when: "{{steps.coin.outputs.result}} == heads"
            arguments: {parameters: [{name: msg, value: "表が出た"}]}
          - name: tails
            template: say
            when: "{{steps.coin.outputs.result}} == tails"
            arguments: {parameters: [{name: msg, value: "裏が出た"}]}

    - name: flaky                 # 2/3 の確率で失敗する
      retryStrategy:
        limit: "5"
      script:
        image: python:3.12-alpine
        command: [python]
        source: |
          import random, sys
          sys.exit(0 if random.randint(1, 3) == 1 else 1)

    - name: coin
      script:
        image: python:3.12-alpine
        command: [python]
        source: |
          import random
          print(random.choice(["heads", "tails"]))

    - name: say
      inputs:
        parameters: [{name: msg}]
      container:
        image: busybox
        command: [echo, "{{inputs.parameters.msg}}"]
```

```bash
argo submit retry.yaml --watch
```

- `flaky` の下に `flaky(0)` `flaky(1)` … と試行回数ぶんのノードが並ぶ
- `heads` / `tails` のどちらかが Skipped になる

何度か submit して、結果が変わるのを見る。

失敗したワークフローを途中から再実行したいときは `argo retry <workflow名>` で、失敗したステップ以降だけが再実行される。

---

## 6. WorkflowTemplate と CronWorkflow（5分）

毎回 YAML を submit するのではなく、クラスターに「型」として登録しておき、そこから実行・定期実行したい場面。

`template.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: greet
spec:
  entrypoint: main
  arguments:
    parameters: [{name: name, value: world}]
  templates:
    - name: main
      inputs:
        parameters: [{name: name}]
      container:
        image: busybox
        command: [echo, "hello {{inputs.parameters.name}}"]
```

```bash
argo template create template.yaml
argo submit --from workflowtemplate/greet -p name=template --watch
```

UI の Workflow Templates からも SUBMIT ボタンで実行できる（パラメータ入力欄も出る）。

`cron.yaml`（登録済みテンプレートを毎分実行する）

```yaml
apiVersion: argoproj.io/v1alpha1
kind: CronWorkflow
metadata:
  name: greet-every-minute
spec:
  schedule: "* * * * *"
  workflowSpec:
    workflowTemplateRef:
      name: greet
```

```bash
argo cron create cron.yaml
argo cron list
# 1〜2分待ってから
argo list
```

`greet-every-minute-xxxxx` が毎分増えていけば OK。確認したら止める。

```bash
argo cron delete greet-every-minute
```

---

## 7. 片付け（2分）

```bash
kind delete cluster --name argo
```

---

## ここまでで押さえたこと

| やりたいこと | 書き方 |
|---|---|
| 1ステップの中身を定義する | `templates` に `container` / `script` |
| 実行ごとに値を変える | `arguments.parameters` → `inputs.parameters` |
| 直列・並列に並べる | `steps`（外側が直列、内側が並列） |
| 依存関係で並べる | `dag.tasks` の `dependencies` |
| 前のステップの結果を使う | `script` の標準出力 → `outputs.result` |
| 落ちたらやり直す | `retryStrategy` / `argo retry` |
| 結果で分岐する | `when` |
| 型として登録・定期実行 | `WorkflowTemplate` / `CronWorkflow` |

## 参考

- [Argo Workflows 公式ドキュメント](https://argo-workflows.readthedocs.io/en/latest/)
- [Quick Start](https://argo-workflows.readthedocs.io/en/latest/quick-start/)
- [Walk Through（公式チュートリアル）](https://argo-workflows.readthedocs.io/en/latest/walk-through/)
- [argoproj/argo-workflows Releases](https://github.com/argoproj/argo-workflows/releases)
- [kind Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/)
