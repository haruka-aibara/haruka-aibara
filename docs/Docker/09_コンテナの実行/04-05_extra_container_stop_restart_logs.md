# Dockerコンテナの基本

## 概要
Dockerコンテナはアプリケーションとその依存関係を一つのパッケージとして実行できる軽量な実行環境です。

## 主要概念
コンテナはDockerイメージのインスタンスであり、独立した環境でアプリケーションを実行します。

## コンテナ管理コマンド

### コンテナの停止
```bash
docker container stop [コンテナID/コンテナ名]
```
実行中のコンテナを停止します。SIGTERMシグナルを送信し、一定時間後にSIGKILLを送信します。

**例:**
```bash
docker container stop mycontainer
```

### コンテナの再起動
```bash
docker container restart [コンテナID/コンテナ名]
```
停止中または実行中のコンテナを再起動します。内部的には停止と起動を連続して実行します。

**例:**
```bash
docker container restart mycontainer
```

**オプション:**
- `--time, -t`: 停止までの待機時間（秒）を指定

### コンテナログの確認
```bash
docker container logs [コンテナID/コンテナ名]
```
コンテナの標準出力（STDOUT）と標準エラー出力（STDERR）のログを表示します。

**例:**
```bash
docker container logs mycontainer
```

**主なオプション:**
- `--follow, -f`: ログをリアルタイムに表示し続ける
- `--tail=n`: 最新のn行のみ表示
- `--timestamps, -t`: タイムスタンプを表示

```bash
# 例: 最新10行のログをタイムスタンプ付きで表示
docker container logs --tail=10 -t mycontainer
```
