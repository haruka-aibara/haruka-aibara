# Ansible scriptモジュール講座

## 1. 概要と重要性

scriptモジュールは、Ansibleでローカルスクリプトをリモートホストで実行するための強力なツールです。このモジュールを活用することで、既存のスクリプトをAnsible環境に簡単に統合できます。

## 2. 主要概念の理論的説明

scriptモジュールは、管理ノード上のスクリプトファイルをターゲットホストにコピーし、実行します。これにより、複雑な操作を単一のタスクとして実行できます。

## 3. 基本的な使用方法

### 3.1 基本構文

```yaml
- name: スクリプトを実行する
  script: パス/スクリプト名.sh
```

### 3.2 実行例

```yaml
- name: メンテナンススクリプトを実行
  script: scripts/system_maintenance.sh
```

## 4. オプションパラメータ

| パラメータ | 説明 | 例 |
|------------|------|-----|
| `chdir` | スクリプト実行前に移動するディレクトリ | `chdir: /tmp` |
| `creates` | 指定したファイルが存在する場合、スクリプトをスキップ | `creates: /var/log/setup_complete` |
| `removes` | 指定したファイルが存在しない場合、スクリプトをスキップ | `removes: /tmp/lockfile` |
| `args` | スクリプトに渡す引数 | `args: -v -f config.ini` |

## 5. 実践的な例

### 5.1 引数を渡す例

```yaml
- name: 引数付きでスクリプトを実行
  script: tools/data_processor.py
  args:
    args: "/var/data/input.csv /var/data/output.json"
```

### 5.2 条件付き実行

```yaml
- name: インストールスクリプトを条件付きで実行
  script: setup/install_app.sh
  args:
    creates: /opt/application/installed.flag
```

### 5.3 実行前にディレクトリを変更

```yaml
- name: 特定ディレクトリでスクリプトを実行
  script: maintenance/cleanup_logs.sh
  args:
    chdir: /var/log
```

## 6. 環境変数の活用

```yaml
- name: 環境変数を渡してスクリプトを実行
  script: tools/configure_service.sh
  environment:
    SERVICE_PORT: 8080
    DEBUG_MODE: "true"
    CONFIG_PATH: "/etc/myapp/config.yml"
```

## 7. 戻り値の確認と条件分岐

```yaml
- name: ステータスチェックスクリプトを実行
  script: monitoring/check_status.sh
  register: status_result

- name: 結果に基づいて処理
  debug:
    msg: "ステータスチェック結果: {{ status_result.stdout }}"
  when: status_result.rc == 0
```

## 8. 注意点と制限事項

- スクリプトはターゲットホスト上で実行されます（管理ノード上ではありません）
- スクリプトの実行権限が適切に設定されていることを確認してください
- 大量のデータを出力するスクリプトは、レスポンスの遅延を引き起こす可能性があります
- セキュリティ上の理由から、スクリプトの内容と目的を十分に理解してから実行してください

## 9. ベストプラクティス

- スクリプトは冪等性（何度実行しても同じ結果になる性質）を持つように設計する
- スクリプトで明示的なエラーコードを返し、Ansible側で適切に処理する
- 長時間実行されるスクリプトには非同期実行オプションを検討する
- スクリプトはバージョン管理システムで管理し、変更履歴を追跡する

## 10. まとめ

scriptモジュールは既存のスクリプトをAnsible環境に統合するための効率的な手段です。適切に活用することで、複雑な操作も簡単にタスク化できます。スクリプトの冪等性を確保し、適切なエラー処理を実装することで、より信頼性の高い自動化が実現できます。
