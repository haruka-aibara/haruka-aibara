以下の devcontainer template に以下の手動設定をすべて組み込んであるため、old に移動します。

`ghcr.io/haruka-aibara/devcontainer-templates/haruka-aibara-dev-env:latest`

## AWS CLI インストールと初期設定
https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/getting-started-install.html

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

```bash
aws configure
```

```bash
AWS Access Key ID [None]: xx
AWS Secret Access Key [None]: xx
Default region name [None]: ap-northeast-1
Default output format [None]: json
```
