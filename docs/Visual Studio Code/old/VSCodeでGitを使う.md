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
```bash
source .bashrc
```

git 最新化

https://git-scm.com/download/linux

```bash
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
