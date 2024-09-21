## 参考記事

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
