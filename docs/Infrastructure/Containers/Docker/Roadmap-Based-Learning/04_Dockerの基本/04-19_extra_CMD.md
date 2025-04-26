# Docker講義：CMD命令

## 概要
CMD命令はDockerコンテナ起動時に実行されるデフォルトコマンドを指定する重要な命令です。

## 理論的説明
CMD命令はコンテナ内のプロセスを定義し、コンテナを実行可能なアプリケーションとして機能させる役割を持ちます。

## CMD命令の基本

### 構文
CMDには3つの形式があります：

```dockerfile
# 形式1: シェル形式
CMD コマンド パラメータ1 パラメータ2

# 形式2: EXEC形式（推奨）
CMD ["実行ファイル", "パラメータ1", "パラメータ2"]

# 形式3: ENTRYPOINTのパラメータとして使用
CMD ["パラメータ1", "パラメータ2"]
```

### 基本的な使用例

```dockerfile
# Webサーバーの例
FROM nginx
CMD ["nginx", "-g", "daemon off;"]

# シンプルなPythonアプリの例
FROM python:3.9
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]
```

### 特徴と注意点

1. **一つのDockerfileで一つのCMD**：
   - 複数のCMD命令がある場合、最後の1つだけが有効になります

2. **実行時の上書き**：
   - `docker run イメージ名 コマンド` でCMDを上書き可能です
   - 例: `docker run nginx ls -la` （nginxを起動せずにlsコマンドを実行）

3. **ENTRYPOINT との違い**：
   - CMDはコンテナ実行時に完全に上書き可能
   - ENTRYPOINTは上書きしにくく、コンテナに固定の動作を持たせたい場合に使用

4. **シェル形式 vs EXEC形式**：
   - シェル形式: `CMD nginx -g "daemon off;"`
     - `/bin/sh -c` 経由で実行される
     - 環境変数の展開が可能
     - PID 1がシェルになる
   
   - EXEC形式（推奨）: `CMD ["nginx", "-g", "daemon off;"]`
     - シェルを介さずに直接実行
     - PID 1が指定したプロセスになる
     - シグナルが適切に処理される
     - 環境変数は展開されない点に注意

### 実践的な例

```dockerfile
# 1. シンプルなHTTPサーバー
FROM python:3.9-slim
WORKDIR /app
COPY . .
# コンテナ起動時にPythonのHTTPサーバーを起動
CMD ["python", "-m", "http.server", "8080"]
```

```dockerfile
# 2. Node.jsアプリケーション
FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
# npmスクリプトを実行
CMD ["npm", "start"]
```

### ベストプラクティス

- EXEC形式を使用する: `CMD ["実行ファイル", "パラメータ"]`
- シェル処理が必要な場合は明示的に記述: `CMD ["/bin/sh", "-c", "echo $HOME"]`
- 長時間実行するプロセスをCMDに指定する（フォアグラウンドでの実行）
- 複雑なスタートアップロジックは別のスクリプトにまとめ、それをCMDで呼び出す
