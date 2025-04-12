# Status Code 127 の対処
sudo apt install libnss3-dev
参考: https://qiita.com/taikomegane/items/58184ea359788ff32147#%EF%BC%94status-code-127%E3%82%92%E8%A7%A3%E6%B1%BA%E3%81%99%E3%82%8B

# WSL2 Ubuntu に Edge をインストールする
## Microsoftの署名キーを追加
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-edge.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list'

## Edgeをインストール
sudo apt update
sudo apt install microsoft-edge-stable
