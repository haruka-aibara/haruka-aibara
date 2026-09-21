以下の devcontainer template に以下の手動設定をすべて組み込んであるため、old に移動します。

`ghcr.io/haruka-aibara/devcontainer-templates/haruka-aibara-dev-env:latest`

### VScode 拡張機能をインストール

1. **HashiCorp Terraform**
   - https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform

### Settings.json を編集する

#### Terraform の保存時に自動フォーマットする
https://marketplace.visualstudio.com/items?itemName=hashicorp.terraform#formatting
```
"[terraform]": {
  "editor.defaultFormatter": "hashicorp.terraform",
  "editor.formatOnSave": true,
  "editor.formatOnSaveMode": "file"
},
"[terraform-vars]": {
  "editor.defaultFormatter": "hashicorp.terraform",
  "editor.formatOnSave": true,
  "editor.formatOnSaveMode": "file"
}
```

## tenv(Terraform 仮想環境) 関連設定
※ Terraform のバージョン管理は tenv で行うため、個別に Terraform をインストールしない。

tenv 有効化
```bash
sudo snap install tenv
tenv tf install latest-stable
```

tenvのterraformにPATHを通すため .bashrc に以下を追記
```bash
# tenv
export PATH=$(tenv update-path):$PATH
```

```bash
source .bashrc
```
