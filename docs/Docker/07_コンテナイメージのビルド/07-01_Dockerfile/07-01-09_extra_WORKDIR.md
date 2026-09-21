# Docker講義: WORKDIR

## 概要
WORKDIRはDockerfile内でコンテナの作業ディレクトリを設定するための命令で、コンテナ内のファイル操作の基準点となります。

## 理論的説明
WORKDIRはコンテナ内の現在の作業ディレクトリを指定し、後続のRUN、CMD、ENTRYPOINT、COPY、ADDなどの命令の実行場所に影響します。

## WORKDIRの基本

### 構文
```dockerfile
WORKDIR /path/to/directory
```

### 主な用途
- コンテナ内での作業ディレクトリの設定
- 後続命令の実行場所の指定
- ファイルパスの基準点の設定

### 使用例

**基本的な使用方法:**
```dockerfile
FROM ubuntu:20.04
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]
```

この例では、`/app`ディレクトリが作業ディレクトリとして設定され、後続のすべての命令はこのディレクトリを基準に実行されます。

### 複数のWORKDIR命令

WORKDIRは複数回使用でき、相対パスを使用した場合は前のWORKDIRからの相対パスとなります：

```dockerfile
FROM ubuntu:20.04
WORKDIR /app
WORKDIR src
WORKDIR client
# 実際の作業ディレクトリは /app/src/client となります
```

### WORKDIRを使用する利点

1. **明確なファイル構造**: コンテナ内のファイル配置が明確になります
2. **相対パスの簡略化**: 後続の命令でのパス指定が簡潔になります
3. **保守性の向上**: Dockerfileの可読性と保守性が向上します

### WORKDIRを使用しない場合の問題点

WORKDIRを使用せずに絶対パスを多用すると以下の問題が発生しやすくなります：

- コードの重複
- エラーの発生リスク増加
- Dockerfileの可読性低下

### ベストプラクティス

1. **絶対パスを使用する**: 予測可能な結果を得るため、WORKDIRでは絶対パスを使用しましょう
2. **自動ディレクトリ作成**: 指定したディレクトリが存在しない場合は自動的に作成されます
3. **環境変数の活用**: WORKDIRでは環境変数も使用できます
   ```dockerfile
   ENV APP_HOME /app
   WORKDIR $APP_HOME
   ```

### よくある間違い

1. **存在しないユーザーのホームディレクトリ指定**: 
   ```dockerfile
   # 間違い例
   WORKDIR ~/app  # コンテナ内では "~" が展開されない場合がある
   
   # 正しい例
   WORKDIR /home/user/app  # 絶対パスを使用する
   ```

2. **WORKDIRとCDの混同**: 
   ```dockerfile
   # 間違い例
   RUN cd /app && npm install  # 一時的な変更のみ
   
   # 正しい例
   WORKDIR /app
   RUN npm install  # 作業ディレクトリが永続的に変更される
   ```

### まとめ

- WORKDIRはDockerfile内で作業ディレクトリを設定する重要な命令です
- 絶対パスを使用し、必要に応じて環境変数を活用しましょう
- 適切なWORKDIRの使用はDockerfileの可読性と保守性を向上させます
