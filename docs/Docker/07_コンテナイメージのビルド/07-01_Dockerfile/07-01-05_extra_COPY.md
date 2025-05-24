# Dockerにおける COPY コマンド

## 概要
COPY コマンドはホストマシンからコンテナイメージへファイルやディレクトリをコピーするための重要な Dockerfile 命令です。

## 基本概念
COPY 命令はビルドコンテキスト内のファイルをイメージのファイルシステムに直接コピーし、ADD とは異なり単純なコピー操作のみを行います。

## 基本的な使い方

### 基本構文
```dockerfile
COPY <ソースパス> <送信先パス>
```

### 具体的な例
```dockerfile
# 単一ファイルのコピー
COPY app.js /app/

# 複数ファイルのコピー
COPY package.json package-lock.json /app/

# ディレクトリ全体のコピー
COPY src/ /app/src/

# ワイルドカードの使用
COPY *.txt /app/texts/
```

## COPY の特徴と挙動

### パスの解釈
- ソースパスはビルドコンテキストからの相対パスです
- 送信先パスは絶対パスまたはWORKDIR（作業ディレクトリ）からの相対パスです
- 送信先パスが存在しない場合は自動的に作成されます

### 権限と所有者
- コピーされたファイルとディレクトリのUIDとGIDはデフォルトで0（root）になります
- `--chown` フラグを使用して所有者とグループを指定できます：
  ```dockerfile
  COPY --chown=user:group files/ /app/
  ```

### パフォーマンスと注意点
- `.dockerignore` ファイルを使用して、不要なファイルがコピーされないようにしましょう
- COPYを使用する前に、関連するディレクトリが作成されていることを確認しましょう
- レイヤーの最適化のため、変更頻度の低いファイルを先にコピーしましょう

## ADD との違い
- COPY は単純なローカルファイルのコピーのみを行います
- ADD は追加機能（リモートURLからのダウンロード、tar自動展開）を持ちます
- 単純なコピー操作には常に COPY が推奨されます（Dockerのベストプラクティス）

## COPY の実践的な使用例

### Node.jsアプリケーションの例
```dockerfile
FROM node:14

WORKDIR /app

# 依存関係ファイルを先にコピー（変更頻度が低い）
COPY package.json package-lock.json ./

# 依存関係のインストール
RUN npm install

# アプリケーションコードをコピー（変更頻度が高い）
COPY src/ ./src/

CMD ["node", "src/index.js"]
```

### 所有者を指定した例
```dockerfile
FROM ubuntu:20.04

# アプリ用ユーザーの作成
RUN useradd -ms /bin/bash appuser

# ファイルを特定のユーザー権限でコピー
COPY --chown=appuser:appuser files/ /home/appuser/files/

USER appuser
```

## まとめ
- COPY はホストからコンテナへのファイルコピーに最適な命令です
- 単純なコピー操作には ADD より COPY を使用しましょう
- レイヤーキャッシュを最適化するために、変更頻度に基づいてファイルをコピーする順序を考慮しましょう
