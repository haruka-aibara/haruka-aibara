
## GitHub.com 公式のブランチ名表示用 .sh

https://github.com/git/git/tree/v2.31.1/contrib/completion

## 設定手順


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
