# Ansible copyモジュール講座

## copyモジュールの概要と重要性
Ansibleのcopyモジュールは、管理ノードからターゲットホストへファイルをコピーするための基本的かつ重要な機能を提供します。インフラ構成管理において設定ファイルの配布は頻繁に必要となる操作であり、このモジュールの理解は自動化の第一歩となります。

## 主要概念の理論的説明
copyモジュールは、指定したソースファイルをリモートホストの指定した場所に正確にコピーし、必要に応じてパーミッションやオーナー情報も設定できます。べき等性（idempotency）を備えており、同一内容のファイルが既に存在する場合は再コピーを行わないため、効率的な運用が可能です。

## 基本的な使用方法

### モジュールの基本構文
```yaml
- name: 設定ファイルをコピー
  copy:
    src: /path/to/local/file.conf
    dest: /path/on/remote/file.conf
```

### 主要パラメータ

| パラメータ | 説明 | 必須 |
|------------|------|------|
| src | コピー元のファイルパス（絶対パスまたはroles内の相対パス） | はい |
| dest | コピー先のファイルパス（絶対パス） | はい |
| mode | ファイルのパーミッション（例: '0644'） | いいえ |
| owner | ファイルの所有者 | いいえ |
| group | ファイルのグループ | いいえ |
| backup | コピー前に既存ファイルのバックアップを作成するか（yes/no） | いいえ |
| content | srcの代わりに直接指定するコンテンツ | いいえ |

## 実践的な使用例

### 例1: 基本的なファイルコピー
```yaml
- name: シンプルなnginx設定ファイルをコピー
  copy:
    src: files/tokyo_nginx.conf
    dest: /etc/nginx/conf.d/default.conf
    mode: '0644'
```

### 例2: バックアップを取りながらのコピー
```yaml
- name: バックアップを取りながらSSH設定をコピー
  copy:
    src: templates/secure_sshd.conf
    dest: /etc/ssh/sshd_config
    owner: root
    group: root
    mode: '0600'
    backup: yes
```

### 例3: 直接コンテンツを指定
```yaml
- name: ヘルスチェック用のHTMLファイルを作成
  copy:
    content: "<html><body>システム正常稼働中</body></html>"
    dest: /var/www/html/health.html
    mode: '0644'
```

## 応用テクニック

### ディレクトリ全体のコピー
```yaml
- name: 設定ディレクトリ全体をコピー
  copy:
    src: files/hokkaido_config/
    dest: /opt/application/config/
    mode: '0755'
    owner: appuser
    group: appgroup
```

### テンプレート変数との使い分け
copyモジュールは静的ファイルのコピーに適していますが、変数を含むファイルが必要な場合は`template`モジュールを検討してください。

```yaml
# copyモジュールの場合（静的ファイル）
- copy:
    src: files/sakura_db.conf
    dest: /etc/app/db.conf

# templateモジュールの場合（変数を含む）
- template:
    src: templates/fuji_db.conf.j2
    dest: /etc/app/db.conf
```

### ファイル更新時の通知
```yaml
- name: Webサーバー設定をコピー
  copy:
    src: files/osaka_httpd.conf
    dest: /etc/httpd/conf/httpd.conf
  notify: restart apache
```

## べき等性の理解

copyモジュールは、ファイルのチェックサムを比較し、内容が同じ場合はコピー操作をスキップします。これにより：

1. 不要な変更が発生しない
2. Playbookの実行が高速化される
3. 変更があった場合のみハンドラーが実行される

## トラブルシューティング

### よくあるエラー

1. **パーミッションエラー**:
   ```
   fatal: [target]: FAILED! => {"msg": "指定されたファイルにアクセスできません"}
   ```
   ⇒ Ansibleユーザーのソースファイル読み取り権限を確認

2. **ディレクトリ存在エラー**:
   ```
   fatal: [target]: FAILED! => {"msg": "指定されたパスのディレクトリが存在しません"}
   ```
   ⇒ 先に`file`モジュールでディレクトリを作成

### デバッグとベストプラクティス

- `-v`オプションで詳細情報を確認
- `--check`モジュールで実行前に変更をシミュレーション
- ターゲットホストのSELinuxコンテキストに注意

## まとめ

copyモジュールは単純ながら強力なツールです。適切に使いこなすことで、一貫性のある環境構築が実現できます。変数が必要な場合はtemplateモジュールとの使い分けを意識し、パーミッションやオーナーの設定も合わせて行うことで、より安全な構成管理が可能になります。
