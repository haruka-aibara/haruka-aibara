参考記事: https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/wsl-vscode


1. Remote Development インストール

https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack

3. Linux ディストリビューションを更新する
```
sudo apt-get update
sudo apt-get install wget ca-certificates
```

3. Visual Studio Code を起動する。

4. Ctrl + Shift + P キーを同時押しする。

5. 上部に表示されるコマンドパレットに「WSL」と入力し、「WSL: Connect to WSL」をクリックする。

![image](https://github.com/user-attachments/assets/0a50892e-a755-4ef9-9705-f45dcad71eab)

7. 画面左下に WSL: ubuntu と表示されていれば完了です。

![image](https://github.com/user-attachments/assets/49f529bf-ac14-42ac-9b68-3789c277ce49)
