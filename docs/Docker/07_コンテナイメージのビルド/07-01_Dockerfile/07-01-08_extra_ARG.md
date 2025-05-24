# Docker講義: ARG

## 概要
ARGはDockerfileでビルド時に利用できる変数を定義するための命令で、イメージの柔軟な構築を可能にします。

## 理論的説明
ARG命令はビルド時のみ有効な変数を定義し、イメージ実行時には利用できないという点でENV命令と異なります。

## ARGの基本的な使い方

### 基本構文
```dockerfile
ARG <変数名>[=<デフォルト値>]
```

### 使用例
```dockerfile
ARG VERSION=latest
FROM ubuntu:${VERSION}
```

## ARGの特徴

### ビルド時のみ有効
- ARGで定義された変数はビルド時にのみ存在し、コンテナ実行時には存在しません
- 実行時にも変数が必要な場合はENVを使用する必要があります

### ARGのスコープ
- ARGはFROM命令の前後で異なる扱いを受けます
- FROM命令前に定義されたARGはFROM命令でのみ使用可能です
- FROM後に再定義する必要があります

```dockerfile
# FROM前で定義
ARG VERSION=20.04

# ここでVERSIONが使える
FROM ubuntu:${VERSION}

# FROM後に再度定義が必要
ARG VERSION
RUN echo $VERSION > /etc/version
```

### ビルド時に値を指定する
```bash
docker build --build-arg VERSION=22.04 -t myapp .
```

### デフォルト値
- ARG命令ではデフォルト値を設定できます
- デフォルト値を設定しておくと、--build-argで指定がない場合はデフォルト値が使用されます

### 事前定義ARG
Dockerには事前定義された以下のARG変数があります：
- HTTP_PROXY
- http_proxy
- HTTPS_PROXY
- https_proxy
- FTP_PROXY
- ftp_proxy
- NO_PROXY
- no_proxy

これらは特別に、ARGで明示的に定義しなくても`--build-arg`で指定可能です。

### ENVとARGの関係
- ENVで定義された変数はARGよりも優先されます
- 同じ名前の変数がARGとENVの両方で定義されている場合、ENVの値が使用されます

```dockerfile
ARG VERSION=20.04
ENV VERSION=latest

# この場合、VERSIONはlatestとなる
RUN echo $VERSION
```

## ARGのユースケース

### バージョン管理
異なるバージョンのベースイメージやライブラリを柔軟に選択できます
```dockerfile
ARG PYTHON_VERSION=3.9
FROM python:${PYTHON_VERSION}
```

### ビルドごとに異なる設定
開発環境と本番環境で異なる設定を使用する場合に便利です
```dockerfile
ARG ENV_TYPE=production
COPY ${ENV_TYPE}.config /app/config
```

### ビルド時のみ必要な認証情報
```dockerfile
ARG NPM_TOKEN
RUN echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc && \
    npm install && \
    rm ~/.npmrc
```

## ARGのベストプラクティス

### セキュリティ上の注意点
- ARGで渡された値はイメージの履歴に残るため、パスワードなどの秘密情報をARGで渡すのは避けるべきです
- 代わりにマルチステージビルドやsecretマウントを検討してください

### 複数のFROMステージでのARG
マルチステージビルドでは、各FROMセクションごとにARGを再定義する必要があります

```dockerfile
ARG BASE_IMAGE=ubuntu:20.04

FROM ${BASE_IMAGE} AS build
# ここでBASE_IMAGEは見えない
ARG BASE_IMAGE  # 再定義が必要
RUN echo $BASE_IMAGE > /tmp/base-image

FROM ${BASE_IMAGE} as release
# ここでも再定義が必要
ARG BASE_IMAGE
RUN echo $BASE_IMAGE > /etc/base-image
```

## まとめ
ARG命令はDockerfileの柔軟性を高め、同じDockerfileから異なる設定でイメージをビルドすることを可能にします。ビルド時にのみ必要な情報を渡す手段として、適切に活用しましょう。
