<!-- Space: harukaaibarapublic -->
<!-- Parent: Code Review -->
<!-- Title: AI 時代の CI：何を入れて何を入れないか -->

# AI 時代の CI：何を入れて何を入れないか

「入れられるものは全部入れればいい」——これが一番やってはいけない。

CI に何でも詰め込むと遅くなる。遅くなると開発者が待たなくなる。待たなくなると `--no-verify` や強制マージが出てくる。**CI を無視する文化が生まれたとき、CI はゼロどころかマイナスの価値になる。**

---

## データが示す現実

「AI が生成したコードだから品質が高い」は思い込みだ。

**Veracode が 2025 年に 100 以上の LLM に 80 種類のコーディングタスクを実行させた調査では、AI 生成コードの 45% にセキュリティ脆弱性が含まれていた。**

さらに悪いことに、XSS 対策が機能していたのはわずか 14%（86% が失敗）、ログインジェクションへの対策は 12%（88% が失敗）。モデルのサイズや訓練の進化に関わらず、セキュリティ性能は横ばいで改善していない。

コードを書く速度は上がっている。セキュリティ品質は追いついていない。あるリポジトリ調査では 2025 年 6 月時点で月間のセキュリティ所見数が 2024 年 12 月比で **10 倍**に達した。

つまり CI が最も必要とされているのは「品質が下がったから」ではなく、「量が増えたのに品質が変わらないから」だ。

---

## CI 設計の 3 原則

### 1. ブロックするのは「取り返しがつかないもの」だけ

| 問題の種類 | CI での扱い |
|---|---|
| シークレット漏れ・脆弱性・テスト失敗 | 必ずブロック（git 履歴に残るので一度でも通したらアウト）|
| フォーマット・軽微な Lint 警告 | 自動修正（ブロックではなく修正してコミット）|
| 未使用変数などのコード臭 | 警告のみ（ブロックしない）|

### 2. 速度で層を作り、遅いものはパス限定実行にする

CI が遅いと開発者が待てなくなる。AI がコードを生成する速度は人間より速い分、CI の待ち時間がより相対的に長く感じる。

```
Layer 1（〜1分、全 PR で必ず実行）
Layer 2（1〜5分、Layer 1 通過後に並列実行）
Layer 3（変更があったパスのみ実行）
```

> **Trivy はオールインワンスキャナー**：コンテナ・IaC（Terraform/Kubernetes/Helm/CloudFormation）・シークレット・依存関係・SBOM を1本でカバーする。Layer 2・3 で複数ツールを使う場面の多くを Trivy に集約できる。SAST（コードパターン検出）は Semgrep が担い、それ以外は Trivy、というのが 2025〜2026 年現在の現実的な分担線だ。

### 3. 入れる基準を決める

以下の 3 つをすべて満たすものだけ入れる。

1. **決定論的に動く** — 同じコードに対して毎回同じ結果（flaky でない）
2. **高速 or パス限定実行できる** — 全 PR で 5 分以上かかるなら再考
3. **ブロックする理由が言える** — 「入れた方がよさそう」ではなく「これが通らなかったら prod に出してはいけない理由」がある

---

## 実際のレイヤー構成

### Layer 1：高速・確実・必須（〜1分）

```yaml
- フォーマット（ruff format / prettier）   → 問題があれば自動修正してコミット
- シークレット検出（gitleaks）              → 必ずブロック
- 構文チェック（terraform validate / tsc）  → 必ずブロック
- Lint error のみ（ruff check --select E）  → error のみブロック、warning は無視
```

**フォーマットはブロックではなく自動修正**にすること。AI 生成コードはフォーマットが安定しないことがある。`ruff --fix` を CI 内で実行し、変更があればコミットし直す。開発者がフォーマットを気にしなくていい状態が正しい。

### Layer 2：品質・セキュリティ（1〜5分、並列実行）

```yaml
- テスト + カバレッジ閾値（pytest --cov-fail-under=80）
- 型チェック（mypy --strict / tsc --noEmit）
- SAST（semgrep + bandit）
- 依存関係の脆弱性（pip-audit / npm audit）
```

### Layer 3：対象パスが変化したときのみ実行

```yaml
# Terraform / K8s / Helm ファイルが変更されたときのみ
paths: ['terraform/**', 'k8s/**', 'helm/**']
  → trivy config . / Checkov / terraform plan

# Dockerfile が変更されたときのみ
paths: ['**/Dockerfile', 'docker-compose*.yml']
  → trivy image scan, hadolint

# requirements.txt が変更されたときのみ
paths: ['requirements*.txt', 'package*.json']
  → より詳細な依存関係スキャン
```

---

## ツール選定：比較と選択理由

### シークレット検出：Gitleaks か TruffleHog か

AI はシークレットをコードに直接書きやすい。「とりあえず動かす」コードを生成するとき、環境変数化より定数で書いてしまう。しかも AI が書いた場合、開発者が全行を精査しないことがある。シークレットが一度でも push されたら git 履歴に残る。Layer 1 でのブロックは必須。

| | Gitleaks | TruffleHog |
|---|---|---|
| 速度 | 速い（CI 向き）| 遅い（スキャンが深い）|
| 検証 | 漏れたかどうかのみ | 認証情報がまだ有効かを実際に確認 |
| セットアップ | 簡単 | 設定が必要 |
| カスタムルール | 柔軟 | 対応しているが複雑 |

**CI の Layer 1 には Gitleaks**。速さが重要で、「コードに API キーが書かれているか」を素早く検出するのが目的だから。TruffleHog はインシデント対応や定期的な全履歴スキャンに使う。

なお、FuzzingLabs のベンチマーク（2025）では GPT-5-mini が 84.4% のリコール率でシークレットを検出したのに対し、Gitleaks は 37.5%、TruffleHog はほぼ 0%（構成依存）という結果も出ている。難読化・分割されたシークレットは従来ツールで検出できないケースがある。シークレット検出の精度には限界があると認識した上で、push しない習慣（.env の徹底管理）とツールを組み合わせる。

```yaml
- name: シークレット検出
  uses: gitleaks/gitleaks-action@v2
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### SAST：Semgrep + Bandit の組み合わせ

AI は「動くが安全でないコード」を自信満々に生成する。Veracode の調査で XSS 対策率 14%、ログインジェクション対策率 12%という数字はこれを裏付けている。パターン検出ができる SAST は AI 時代に価値が上がっている。

| | Semgrep | Bandit |
|---|---|---|
| 対応言語 | 20 以上 | Python のみ |
| カスタムルール | 書きやすい | 限定的 |
| 精度（security モード）| false positive ほぼゼロ | Python では高精度 |
| コスト | OSS 版は無料 | 無料 |

**推奨：Semgrep（security モード）+ Bandit を両方使う。** Python プロジェクトなら Bandit が補完的に機能する。Semgrep の "auto" モードは所見が数千件出て雑音になるので、security ルールセットに絞る。

```yaml
- name: Semgrep
  uses: semgrep/semgrep-action@v1
  with:
    config: p/security-audit  # security に絞る

- name: Bandit（Python の場合）
  run: bandit -r src/ -ll  # HIGH 以上のみ
```

`-ll` で HIGH・CRITICAL のみブロック。LOW を全部ブロックにすると雑音で開発者が無視し始める。

### 依存関係セキュリティ：Slopsquatting との戦い

AI は存在しないパッケージを `import` する。これが Slopsquatting の温床だ。

研究で明らかになった数字：
- Python と JavaScript の AI 生成コードサンプル 57.6 万件のうち **約 20% に実在しないパッケージ参照**が含まれていた
- GPT-4 でさえ約 5% の確率でパッケージ名を hallucinate する
- 同じプロンプトを 10 回繰り返したとき、**43% の幻パッケージが毎回同じ名前で出現**した（攻撃者が事前に登録できる）
- 何も入っていない "huggingface-cli"（偽物）は 3 ヶ月で **3 万回以上ダウンロードされた**

```yaml
- name: 依存関係の脆弱性 + 存在確認
  run: pip-audit --requirement requirements.txt

- name: npm 依存関係
  run: npm audit --audit-level=high
```

Python の場合は **依存関係をバージョン固定（`==` 指定）し、ハッシュ検証を有効にする**。

```
# requirements.txt
requests==2.31.0 --hash=sha256:942c5a758f98...
```

npm の場合は `package-lock.json` を必ず git 管理し、CI では `npm ci`（`npm install` ではない）を使う。

**npm については [Socket.dev](https://socket.dev/) も検討価値がある。** `pip-audit` や `npm audit` が「既知の CVE があるか」を見るのに対し、Socket は「このパッケージの動作が怪しいか」をリアルタイムで分析する。インストールスクリプトの挙動、異常なネットワーク通信、難読化されたコードなどを検出できる。

**「Trivy fs でまとめればいいのでは？」という問いへの答え**：Trivy は `trivy fs .` でファイルシステムをスキャンし、Python・npm 等の依存関係の CVE も検出できる。ただし `requirements.txt` を使う場合は直接依存のみのスキャンとなり、推移的依存を含めるには pip freeze 等で完全な一覧を生成してから渡す必要がある。また pip-audit には脆弱な依存関係を自動アップグレードする機能がある。「脆弱性の検出だけでいい」なら Trivy fs に統一できるが、「見つけたら自動修正まで CI で完結させたい」なら pip-audit を残す理由になる。

**OSV-Scanner**（Google / OpenSSF）も 2025 年時点で選択肢に入る。Open Source Vulnerability データベース（OSV）を使い、pip-audit と同様に Python・npm を含む多言語の依存関係をチェックできる。シンプルな CLI で CI への組み込みは容易だが、pip-audit の自動パッチ機能はない。

### Trivy：IaC・コンテナをまとめてスキャン（変更時のみ）

tfsec は 2024 年に Trivy へ統合・開発終了となった。`tfsec .` は `trivy config .` に移行する。Trivy 1 本で Terraform・Kubernetes マニフェスト・Helm チャート・CloudFormation・Dockerfile のミスコンフィグを検出できる。

Trivy は CNCF のコンテナレジストリ Harbor のデフォルトスキャナーであり、GitLab・AWS Security Hub との公式インテグレーションも持つ。GitHub スター数は 2026 年時点で 31,000 を超えており、コンテナ・IaC 領域のデファクトスタンダードになっている。

| スキャン対象 | コマンド |
|---|---|
| IaC（Terraform / K8s / Helm 等）| `trivy config .` |
| コンテナイメージ | `trivy image <image>` |
| ファイルシステム（依存関係含む）| `trivy fs .` |
| Git リポジトリ全体 | `trivy repo .` |

```yaml
- name: Trivy IaC スキャン（Terraform / K8s 変更時のみ）
  if: contains(steps.changed-files.outputs.all, 'terraform/')
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'config'
    scan-ref: '.'
    exit-code: '1'
    severity: 'HIGH,CRITICAL'

- name: Trivy イメージスキャン（Dockerfile 変更時のみ）
  if: contains(steps.changed-files.outputs.all, 'Dockerfile')
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'image'
    image-ref: ${{ env.IMAGE_NAME }}
    exit-code: '1'
    severity: 'HIGH,CRITICAL'
```

**Checkov との使い分け**：Checkov は独立して開発が続いており、独自のコンプライアンスポリシー（CIS Benchmark・PCI-DSS 等）の追加、Terraform plan の JSON ファイルをスキャンして実行後の状態も検証できる点で Trivy config より強い。「ミスコンフィグを検出したい」だけなら Trivy config で十分。「組織固有のポリシーをコード化して管理したい」「plan 後の状態もチェックしたい」なら Checkov を追加する価値がある。その場合は `soft_fail` の閾値を揃えること（揃っていないと CI の挙動が混乱する）。

---

## AI 時代特有の新脅威：AI ツール自体が標的になった

2025 年 8 月、npm のサプライチェーン攻撃で **Claude Code・Cursor・VS Code Continue** などの AI コーディングツールが直接標的になった。

攻撃の手口：
1. 人気の npm パッケージ（Nx）の悪意あるバージョンを公開
2. そのパッケージが Claude Code・Gemini・Amazon Q などの AI CLI ツールを検出
3. AI ツールの MCP（Model Context Protocol）設定に不正なサーバーを注入
4. 以降の AI の出力に隠しインストラクションを混入させ、機密ファイルを外部に送信

これは従来の「悪意あるコードを実行させる」攻撃ではなく、「AI ツールの動作そのものを汚染する」攻撃だ。AI を使う開発者は、AI ツール自体が攻撃の経路になりうることを認識する必要がある。

**対策として CI に入れるもの：**

```yaml
# MCP 設定ファイルの変更を検出して警告
- name: MCP 設定の変更チェック
  run: |
    if git diff HEAD~1 -- '.claude/settings.json' '.continue/config.json' \
       '.cursor/mcp.json' 2>/dev/null | grep -q '^+'; then
      echo "::warning::AI ツールの設定ファイルが変更されています。意図した変更か確認してください"
    fi
```

また、AI ツールの設定ファイル（`.claude/settings.json`, `mcp.json` 等）を git で管理し、PR での変更を必ずレビューする運用を入れておく。

---

## テストカバレッジの注意点

「カバレッジ 80% 以上」で設定する場合、AI 時代では注意が必要だ。

**AI がコードもテストも両方書くと、同じ解釈ミスをしたテストでカバレッジが達成される。** 実装が間違っていてもテストが通る。

カバレッジ閾値は「テストが書かれているか」の最低保証にはなるが、「正しい仕様を検証しているか」の保証にはならない。閾値を満たした = 安全、とは思わない。

仕様から書くテスト（BDD / 受け入れ条件テスト）を別で管理し、「AI が書いたテスト」と「人間が仕様から書いたテスト」を明示的に分けることで、カバレッジの意味を保つ。

---

## 入れない方がいいもの

### AI コードレビュー（PR への自動コメント）

[前の記事で整理した通り](./AIがコードを書くなら、AIレビューは何を見ているのか.md)、AI が書いたコードを AI がレビューする場合、「動くが意図と違う」「仕様の解釈がズレている」は検出できない。セキュリティパターンは SAST が、依存関係は pip-audit が担う。CI の速度を下げるコストに見合わない。

### パフォーマンスベンチマーク

CI 環境のリソース状況により実行時間が変動する。flaky な結果が出るたびに再実行が必要になり、CI への信頼が下がる。パフォーマンスの劣化検知は本番のモニタリング（CloudWatch、Datadog 等）に任せる。

### 全 Lint ルールを一気に error 化

既存プロジェクトへの導入コストが高くなり、常に CI が落ちて形骸化する。まず warning で導入 → 体感してから error に格上げ、という段階を踏む。

### コードカバレッジの極端な高閾値（95% 以上など）

テストを書くことに価値があるのは前提だが、90%+を必須にすると、カバレッジを通すためだけの意味のないテストが生まれる。閾値は 80% 程度に留め、コアロジックのみ別途高い閾値を設定する。

---

## まとめ：ツールと役割の対応

| 問題 | ツール | レイヤー |
|---|---|---|
| シークレット漏れ | gitleaks | L1（必ずブロック）|
| フォーマット | ruff format / prettier | L1（自動修正）|
| 型エラー・構文エラー | mypy / tsc | L1〜L2 |
| セキュリティパターン（XSS, injection 等）| semgrep + bandit | L2 |
| 依存関係の脆弱性 | pip-audit / npm audit | L2 |
| Slopsquatting | pip-audit + ハッシュ検証 + Socket.dev | L2〜L3 |
| IaC セキュリティ（Terraform / K8s 等）| trivy config（旧 tfsec は統合済み）| L3（変更時）|
| コンテナ脆弱性 | trivy image | L3（Dockerfile 変更時）|
| AI ツール設定の汚染 | MCP 設定の変更監視 | L2 |
| テスト | pytest / jest + カバレッジ閾値 80% | L2 |

**Trivy が実質的なデファクトスタンダード**になっている領域：IaC スキャン（tfsec を吸収）、コンテナスキャン、SBOM 生成、ファイルシステムスキャン。SAST（コードパターン検出）は Semgrep が担い、それ以外は Trivy に集約するのが現実的な最短構成だ。

全部入れる必要はない。自分のプロジェクトが何の言語・インフラを使っているかで選ぶ。Python + Terraform なら Layer 1 + semgrep + bandit + pip-audit + tfsec で十分な出発点になる。

重要なのは「入れた理由が言える状態を維持すること」。CI に何が入っているか説明できないまま増やしていくと、やがて全員が結果を無視するようになる。

---

## 参考

- [Veracode: 2025 GenAI Code Security Report](https://www.veracode.com/resources/analyst-reports/2025-genai-code-security-report/)
- [Apiiro: 4x Velocity, 10x Vulnerabilities: AI Coding Assistants Are Shipping More Risks](https://apiiro.com/blog/4x-velocity-10x-vulnerabilities-ai-coding-assistants-are-shipping-more-risks/)
- [Bleeping Computer: AI-hallucinated code dependencies become new supply chain risk](https://www.bleepingcomputer.com/news/security/ai-hallucinated-code-dependencies-become-new-supply-chain-risk/)
- [Socket: Slopsquatting — How AI Hallucinations Are Fueling a New Class of Supply Chain Attacks](https://socket.dev/blog/slopsquatting-how-ai-hallucinations-are-fueling-a-new-class-of-supply-chain-attacks)
- [Trend Micro: Slopsquatting When AI Agents Hallucinate Malicious Packages](https://www.trendmicro.com/vinfo/us/security/news/cybercrime-and-digital-threats/slopsquatting-when-ai-agents-hallucinate-malicious-packages)
- [Socket: Nx packages compromised — supply chain attack targeting AI coding tools](https://socket.dev/blog/nx-packages-compromised)
- [OWASP Top 10 2025: A03 — Software Supply Chain Failures](https://owasp.org/Top10/2025/A03_2025-Software_Supply_Chain_Failures/)
- [Jit: TruffleHog vs. Gitleaks comparison](https://www.jit.io/resources/appsec-tools/trufflehog-vs-gitleaks-a-detailed-comparison-of-secret-scanning-tools)
- [Semgrep: Python static analysis comparison — Bandit vs Semgrep](https://semgrep.dev/blog/2021/python-static-analysis-comparison-bandit-semgrep/)
- [FuzzingLabs: LLMs beating regex in secret detection benchmark](https://x.com/FuzzingLabs/status/1980668916851483010)
- [Addy Osmani: My LLM coding workflow going into 2026](https://addyosmani.com/blog/ai-coding-workflow/)
- [AWS Blog: Your AI Coding Assistants Will Overwhelm Your Delivery Pipeline](https://aws.amazon.com/blogs/enterprise-strategy/your-ai-coding-assistants-will-overwhelm-your-delivery-pipeline-heres-how-to-prepare/)
- [Trivy: All-in-One Security Scanner](https://trivy.dev/)
- [aquasecurity/tfsec: Tfsec is now part of Trivy](https://github.com/aquasecurity/tfsec)
- [tfsec to Trivy migration guide](https://github.com/aquasecurity/tfsec/blob/master/tfsec-to-trivy-migration-guide.md)
- [OSV-Scanner: Vulnerability scanner by Google / OpenSSF](https://google.github.io/osv-scanner/)
- [Trivy: Python coverage](https://trivy.dev/docs/latest/coverage/language/python/)
