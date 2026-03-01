<!-- Space: harukaaibarapublic -->
<!-- Parent: GitHub Actions -->
<!-- Title: 外部イメージの ECR ミラーリングと Inspector スキャン -->

# 外部イメージの ECR ミラーリングと Inspector スキャン

GitHub Actions で `docker run kovetskiy/mark:v15.3.0` のように Docker Hub の外部イメージを直接使うと、いくつかのリスクがある。タグはミュータブルなため supply chain 攻撃の入り口になりうる、Docker Hub のレートリミットで CI が落ちる、CVE が含まれていても気づけない——エンタープライズで使うなら解決しておきたい問題だ。

対策は「ECR にミラーリングして Inspector でスキャンし、digest でピン留めする」。

---

## やること全体像

1. ECR リポジトリを作成
2. 外部イメージを ECR にミラーリング
3. Inspector を ECR に対して有効化（push トリガーで自動スキャン）
4. ECR の digest を取得してワークフローに固定

---

## 1. ECR リポジトリを作成

```bash
aws ecr create-repository \
  --repository-name kovetskiy-mark \
  --region ap-northeast-1 \
  --image-scanning-configuration scanOnPush=true
```

`scanOnPush=true` は ECR 組み込みの Basic スキャン。Inspector を使う場合でも設定しておいて問題ない。

---

## 2. 外部イメージを ECR にミラーリング

```bash
ECR_REGISTRY=123456789012.dkr.ecr.ap-northeast-1.amazonaws.com
REPO=kovetskiy-mark
TAG=v15.3.0

# Docker Hub から pull
docker pull kovetskiy/mark:${TAG}

# ECR にログイン
aws ecr get-login-password --region ap-northeast-1 \
  | docker login --username AWS --password-stdin ${ECR_REGISTRY}

# タグを付けて push
docker tag kovetskiy/mark:${TAG} ${ECR_REGISTRY}/${REPO}:${TAG}
docker push ${ECR_REGISTRY}/${REPO}:${TAG}
```

次のバージョンが出たときも同じ手順。

---

## 3. Inspector を ECR に対して有効化

Inspector v2 を有効化すると、ECR への push をトリガーに自動でスキャンが走る。

```bash
aws inspector2 enable \
  --resource-types ECR \
  --region ap-northeast-1
```

有効化後は ECR コンソール → 対象イメージ → 「脆弱性」タブから結果を確認できる。Security Hub と統合して一元管理することもできる。

---

## 4. Digest を取得して固定する

タグは書き換え可能だが、digest はイメージのコンテンツに紐づくハッシュ値なので不変。**タグが指すイメージが変わっても、digest は変わらない**。

ECR から取得する場合:

```bash
aws ecr describe-images \
  --repository-name kovetskiy-mark \
  --image-ids imageTag=v15.3.0 \
  --region ap-northeast-1 \
  --query 'imageDetails[0].imageDigest' \
  --output text
# → sha256:a1b2c3d4e5f6...
```

docker コマンドで取得する場合:

```bash
docker inspect --format='{{index .RepoDigests 0}}' \
  123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/kovetskiy-mark:v15.3.0
# → 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/kovetskiy-mark@sha256:...
```

---

## 5. ワークフローで digest を使う

取得した digest をワークフローに直書きする。タグをコメントで残しておくと更新時にわかりやすい。

```yaml
docker run --rm \
  -e MARK_USERNAME \
  -e MARK_PASSWORD \
  -e MARK_BASE_URL \
  -v "${GITHUB_WORKSPACE}:/workspace" \
  -w /workspace \
  123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/kovetskiy-mark@sha256:a1b2c3d4... # v15.3.0
  mark -f "$f"
```

タグを書き換えて同じ参照が別のイメージを指すようになっても、digest が違えば pull に失敗する。

---

## IAM 権限（GitHub Actions から ECR を使う場合）

OIDC で認証する場合、IAM ロールに以下のポリシーが必要:

```json
{
  "Effect": "Allow",
  "Action": [
    "ecr:GetAuthorizationToken",
    "ecr:BatchGetImage",
    "ecr:GetDownloadUrlForLayer"
  ],
  "Resource": "*"
}
```

`ecr:GetAuthorizationToken` は ECR 認証のため Resource を `*` にする必要がある（ARN 指定不可）。`BatchGetImage` と `GetDownloadUrlForLayer` はリポジトリ ARN で絞れる。

---

## バージョンアップのときは

mark の新バージョンが出たときのフロー:

1. 上記ミラーリング手順を新タグで実行
2. Inspector のスキャン結果を確認（CRITICAL/HIGH がなければ OK）
3. ワークフローの digest を新しい値に更新
