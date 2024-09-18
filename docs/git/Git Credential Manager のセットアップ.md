## 参考記事

https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/wsl-git#git-credential-manager-setup


1. Git 最新化後、インストールされている GIT が >= v2.39.0 の場合
```
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
```

2. 完了
