## 参考記事

https://docs.github.com/ja/github-cli/github-cli/quickstart

https://github.com/cli/cli/blob/trunk/docs/install_linux.md

## インストールとログイン手順

1. 以下のコマンドを入力する。

```
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
```

2. 以下のコマンドを入力する。

```
sudo apt update
sudo apt install gh
```

3. 以下のコマンドを入力する。

```
gh auth login
```

4. 該当する選択肢を矢印キーで選び Enter キーを押下し進めます。以下はブラウザを開き認証を行う例です。

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
