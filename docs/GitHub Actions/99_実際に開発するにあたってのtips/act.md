# act - GitHub Actionsのローカルテストツール

## 概要
actはGitHub Actionsのワークフローをローカル環境で実行できるツールです。CIのテストをローカルで行うことで、開発効率を向上させることができます。

## インストール方法

### macOS
```bash
brew install act
```

### Linux
```bash
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

### Windows
```bash
choco install act-cli
```

## 基本的な使い方

1. ワークフローの実行
```bash
# デフォルトのワークフローを実行
act

# 特定のワークフローを実行
act -W .github/workflows/specific-workflow.yml

# 特定のイベントをトリガー
act push
act pull_request
```

2. ジョブの指定
```bash
# 特定のジョブのみを実行
act -j build
```

## 主なオプション

- `-n`: ドライラン（実際のコマンドは実行せず、何が実行されるかを表示）
- `-v`: 詳細なログ出力
- `-P`: カスタムイメージの使用
- `--bind`: ホストマシンのファイルシステムをコンテナにマウント

## 注意点

1. Dockerが必要
   - actはDockerを使用してワークフローを実行するため、Dockerのインストールが必要です

2. シークレットの扱い
   - ローカル環境でシークレットを使用する場合は、`.secrets`ファイルを作成するか、環境変数として設定する必要があります

3. 制限事項
   - 一部のGitHub Actionsの機能はローカル環境では完全に再現できない場合があります
   - 特にGitHub固有の機能（例：`checkout`アクション）は制限される可能性があります

## 便利な設定

### .actrcファイル
プロジェクトのルートディレクトリに`.actrc`ファイルを作成することで、デフォルトのオプションを設定できます：

```
-P ubuntu-latest=nektos/act-environments-ubuntu:18.04
--bind
```

## トラブルシューティング

1. パーミッションエラー
```bash
# Dockerのパーミッションを修正
sudo chmod 666 /var/run/docker.sock
```

2. イメージのダウンロードエラー
```bash
# イメージを手動でプル
docker pull nektos/act-environments-ubuntu:18.04
```

## 参考リンク

- [公式リポジトリ](https://github.com/nektos/act)
- [ドキュメント](https://github.com/nektos/act#readme)
