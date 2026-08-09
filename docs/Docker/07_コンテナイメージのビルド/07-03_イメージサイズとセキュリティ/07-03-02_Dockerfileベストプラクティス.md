# Dockerfile ベストプラクティス——セキュリティとサイズの両立

「イメージが 1GB 超えている」「コンテナが root で動いている」「脆弱性スキャンで大量に検出された」——Dockerfile を少し見直すだけで改善できることが多い。

---

## ベースイメージは slim か distroless を選ぶ

| ベースイメージ | サイズ目安 | 向いている用途 |
|---|---|---|
| `python:3.12` | ~1GB | 開発（デバッグツールが揃っている） |
| `python:3.12-slim` | ~150MB | 本番（不要パッケージを削除済み） |
| `python:3.12-alpine` | ~50MB | サイズ最優先（musl libc に注意） |
| `gcr.io/distroless/python3` | ~50MB | シェルなし・最小攻撃面 |

```dockerfile
# Bad: 不必要に大きい
FROM python:3.12

# Good: 本番向け
FROM python:3.12-slim
```

---

## root で動かさない

コンテナが侵害されたときの被害を最小化する。

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# アプリ用ユーザーを作成して切り替え
RUN adduser --disabled-password --gecos "" appuser
USER appuser

CMD ["python", "main.py"]
```

`USER appuser` 以降の命令はすべてそのユーザーで実行される。

---

## マルチステージビルドでビルド成果物だけを本番イメージに含める

```dockerfile
# ステージ1: ビルド
FROM node:20 AS builder
WORKDIR /app
COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build

# ステージ2: 本番（ビルドツールは含まれない）
FROM node:20-slim AS production
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER node
CMD ["node", "dist/index.js"]
```

`builder` ステージの `node_modules` の開発依存（devDependencies）や TypeScript コンパイラは最終イメージに含まれない。

---

## レイヤーキャッシュを活用して再ビルドを速くする

Docker は Dockerfile の上から順に評価し、変更があった行以降のキャッシュを無効化する。「変わりにくいものを上に、変わりやすいものを下に」書く。

```dockerfile
# Bad: コードを先にコピーすると requirements が変わっていなくても pip install が走る
COPY . .
RUN pip install -r requirements.txt

# Good: requirements を先にコピーしてキャッシュを活用する
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
```

---

## 不要なファイルを `.dockerignore` で除外する

```
# .dockerignore
.git
.github
**/__pycache__
**/*.pyc
.env
.env.*
*.log
node_modules
dist
.pytest_cache
```

`.env` がイメージに含まれると、`docker history` や `docker inspect` で内容を見られてしまう。

---

## `RUN` は1行にまとめてレイヤーを減らす

```dockerfile
# Bad: 3レイヤー生成（apt のキャッシュが中間レイヤーに残る）
RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

# Good: 1レイヤー、キャッシュも削除
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*
```

`--no-install-recommends` で推奨パッケージを除外するとさらにサイズを削減できる。

---

## Trivy でイメージをスキャンする

```bash
# Trivy でイメージの脆弱性を確認
trivy image myapp:latest

# CRITICAL / HIGH のみ表示
trivy image --severity CRITICAL,HIGH myapp:latest

# CI で使う場合（EXIT_CODE を設定してパイプラインを止める）
trivy image --exit-code 1 --severity CRITICAL myapp:latest
```

GitHub Actions に組み込む例:

```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:${{ github.sha }}
    severity: CRITICAL,HIGH
    exit-code: 1
```

---

## チェックリスト

- [ ] ベースイメージは slim または distroless を使っている
- [ ] root 以外のユーザーで実行している
- [ ] マルチステージビルドでビルドツールを除いている
- [ ] `.dockerignore` で `.env` やテストファイルを除外している
- [ ] `apt-get` のキャッシュを同一レイヤーで削除している
- [ ] Trivy などで定期的にスキャンしている
