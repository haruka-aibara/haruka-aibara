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

### 追加の拡張機能をインストール

 - HashiCorp Terraform
    - https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform

 - Markdown All in One
   - https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one

 - Markdown Preview Enhanced
   - https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced

 - Markdown Preview Mermaid Support
   - https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid

 - Python
   - https://marketplace.visualstudio.com/items?itemName=ms-python.python

 - Ruff
   - https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff

### Settings.json を編集する

#### マークダウンに画像を貼り付けた際の保存先ディレクトリを定義
```
"markdown.copyFiles.destination": {
  "**/*.md": "assets/${documentBaseName}/"
},
"markdown.copyFiles.overwriteBehavior": "uniqueFilename",
"markdown.editor.drop.copyIntoWorkspace": "always",
"markdown.editor.filePaste.copyIntoWorkspace": "always"
```

#### 保存時に改行必須にする
```
"files.insertFinalNewline": true
```

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
#### Ruff 用
https://qiita.com/LaserBit/items/8dfd410ef65c19053ce2
```
    "[python]": {
        "editor.codeActionsOnSave": {
            "source.fixAll": "explicit",
            "source.organizeImports": "explicit"
        },
        "editor.defaultFormatter": "charliermarsh.ruff"
    },
    "ruff.lineLength": 120,
    "ruff.lint.ignore": [
        "F401"
    ],
    "ruff.lint.preview": true,
    "ruff.lint.select": [
        "C",
        "E",
        "F",
        "W",
        "I"
    ],
    "ruff.logFile": "~/logs/ruff.log",
    "ruff.logLevel": "debug",
    "ruff.nativeServer": "on",
```

### その他 VSCode 設定

#### Mermaid プレビューで AWS アイコンを使えるようにする
https://qiita.com/take_me/items/83769d32c35e99b85ec8

##### 手順
コマンドパレットから

Markdown Preview Enhanced: Customize Preview HTML Head (Global) を選択

html の内容を以下の通り修正

```html
<!-- The content below will be included at the end of the <head> element. -->
<script type="text/javascript">
   const configureMermaidIconPacks = () => {
    window["mermaid"].registerIconPacks([
      {
        name: "logos",
        loader: () =>
          fetch("https://unpkg.com/@iconify-json/logos/icons.json").then(
            (res) => res.json()
          ),
      },
    ]);
  };

  // ref: https://stackoverflow.com/questions/39993676/code-inside-domcontentloaded-event-not-working
  if (document.readyState !== 'loading') {
    configureMermaidIconPacks();
  } else {
    document.addEventListener("DOMContentLoaded", () => {
      configureMermaidIconPacks();
    });
  }
</script>
```

##### 対象サービスの aws アイコンが存在するか確認

以下から検索できます（SNSで検索した場合の例）

https://icones.js.org/collection/logos?s=aws-sns

## unzip インストール
```bash
sudo apt install unzip
```

## jq インストール
```bash
sudo apt install jq
```

## 圧縮関連 インストール
```
sudo apt-get install zip gzip tar
```

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

## Python 関連設定
https://docs.astral.sh/uv/getting-started/installation/

https://qiita.com/LaserBit/items/8dfd410ef65c19053ce2

uv インストール
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

```bash
source $HOME/.cargo/env
```

ruff 有効化
```bash
uv tool install ruf
uv tool update-shell
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

## Git 関連設定

git インストール
https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/wsl-git
```bash
sudo apt-get install git
```

https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/wsl-git#git-config-file-setup
```bash
git config --global user.name "Your Name"
git config --global user.email "youremail@domain.com"
```

git の branch を表示する
https://qiita.com/m-tmatma/items/d9ceba9118d5f6c1be83


1. .bashrc に以下の記述を追加する。

```
# display git branch name
if [ -e /etc/bash_completion.d/git-prompt ]; then
    source /etc/bash_completion.d/git-prompt
    PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $(__git_ps1 " (%s)") \$ '
fi
```

2. 以下のコマンドを入力する。
```
source .bashrc
```

git 最新化

https://git-scm.com/download/linux

```
sudo add-apt-repository ppa:git-core/ppa
sudo apt update; sudo apt install git
```

github cli インストール
https://docs.github.com/ja/github-cli/github-cli/quickstart

https://github.com/cli/cli/blob/trunk/docs/install_linux.md

```
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
```


```
sudo apt update
sudo apt install gh
```


```
gh auth login
```


```
? What account do you want to log into? GitHub.com
? What is your preferred protocol for Git operations on this host? HTTPS
? Authenticate Git with your GitHub credentials? (Y/n) Y
? How would you like to authenticate GitHub CLI? Login with a web browser
! First copy your one-time code: XXXX-XXXX
Press Enter to open github.com in your browser... 
✓ Authentication complete.
~~~~~~~~~~~~~~~~~~
✓ Logged in as haruka-aibara
```

2FA（未設定の場合）
https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa/configuring-two-factor-authentication

git for windows インストール（未インストールの場合）
https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/wsl-git#git-credential-manager-setup

https://gitforwindows.org/

デフォルトブランチを「main」にする以外は全てデフォルトでOK

git credential manager のセットアップ
https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/wsl-git#git-credential-manager-setup
https://code.visualstudio.com/docs/remote/troubleshooting#_sharing-git-credentials-between-windows-and-wsl

1. ubuntu でコマンドを入力する。
```
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
```

2. Windows で PowerShell を起動し以下のコマンドを入力する。
```
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager-core.exe"
```


おまけ：その他 git 参考情報
https://code.visualstudio.com/docs/sourcecontrol/overview#_working-in-a-git-repository

https://training.github.com/downloads/github-git-cheat-sheet.pdf


## Linux 版 Anaconda インストール
https://www.anaconda.com/download/success から最新の 64-bit Installer
参考：https://www.salesanalytics.co.jp/datascience/datascience141/#LinuxAnaconda

2025-03-30 時点の最新

wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh

bash Anaconda3-2024.10-1-Linux-x86_64.sh

source .bashrc

conda config --set auto_activate_base false

eval "$(/home/haruka_aibara/anaconda3/bin/conda shell.bash hook)" 

conda install anaconda-navigator

### システムパッケージの更新
sudo apt-get update

### 必要なライブラリのインストール（apt-get）
sudo apt-get install \
    libpci3 \
    libgl1-mesa-glx \
    libegl1-mesa \
    libxrandr2 \
    libxss1 \
    libxcursor1 \
    libxcomposite1 \
    libasound2 \
    libxi6 \
    libxtst6 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libx11-xcb-dev \
    libglu1-mesa-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libxcb-xinerama0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xkb1 \
    '^libxcb.*-dev'

### Conda関連のインストール
conda install -c anaconda qt qtpy
conda install -c conda-forge qt

### デバッグ用の環境変数設定（必要な場合のみ）
export QT_DEBUG_PLUGINS=1

これで、VSCode のターミナルで「anaconda-navigator」と入力すると
anaconda-navigator が起動します。
