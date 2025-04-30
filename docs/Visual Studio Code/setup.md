# 開発環境構築手順

## WSL インストール
参考記事: [WSL を使用して Windows に Linux をインストールする方法](https://learn.microsoft.com/ja-jp/windows/wsl/install)

参考記事: [WSL 開発環境を設定する](https://learn.microsoft.com/ja-jp/windows/wsl/setup/environment#set-up-your-linux-username-and-password)


```sh
wsl --install
```

```bash
sudo apt update && sudo apt upgrade
```

## VSCode 関連設定
https://code.visualstudio.com/docs/?dv=win64user

### Remote Development の拡張機能をインストール
参考記事: https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/wsl-vscode

https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack

### VSCode から WSL を開く
以後、VSCodeからWSLを開き操作を行ってください。

### Settings.json を編集する

#### 保存時に改行必須にする
```
"files.insertFinalNewline": true
```

### Rainbow CSV
https://marketplace.visualstudio.com/items/?itemName=mechatroner.rainbow-csv

## もろもろインストール
```bash
sudo apt install unzip jq zip gzip tar htop tree
```
