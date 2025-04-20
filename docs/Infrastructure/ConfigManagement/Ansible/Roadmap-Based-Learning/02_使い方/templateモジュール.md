# Ansible templateモジュール講座

## 概要と重要性
templateモジュールは、Jinja2テンプレートエンジンを利用して動的にファイルを生成する強力なツールであり、環境ごとに異なる設定ファイルを効率的に管理できます。

## 主要概念の理論的説明
テンプレートファイルに変数やフィルタ、条件文などを記述し、Ansible実行時に実際の値で置き換えることで、環境に適した設定ファイルを自動生成します。

## templateモジュールの基本構文

```yaml
- name: テンプレートから設定ファイルを生成
  template:
    src: コンフィグ_テンプレート.j2
    dest: /etc/アプリケーション/コンフィグ.conf
    owner: appuser
    group: appgroup
    mode: '0644'
    backup: yes
```

## Jinja2テンプレートの基本要素

### 変数の使用法

```jinja
# サーバー設定
server_name: {{ サーバー名 }}
max_connections: {{ 最大接続数 }}
timeout: {{ タイムアウト値 | default(30) }}
```

### 条件分岐

```jinja
{% if 環境 == "本番" %}
log_level = INFO
{% else %}
log_level = DEBUG
{% endif %}
```

### ループ処理

```jinja
# データベース接続設定
{% for db in データベースリスト %}
[database.{{ db.名前 }}]
host = {{ db.ホスト }}
port = {{ db.ポート | default(5432) }}
user = {{ db.ユーザー }}
{% endfor %}
```

### フィルタの活用例

```jinja
# セキュリティ設定
password_hash: {{ パスワード | password_hash('sha512') }}
hostname: {{ インベントリ_ホスト名 | upper }}
config_path: {{ パス | regex_replace('^/opt/', '/usr/local/') }}
```

## 実践例: Webサーバー設定の自動生成

### テンプレートファイル (webサーバー_設定.j2)

```jinja
server {
    listen {{ ポート | default(80) }};
    server_name {{ ドメイン名 }};
    
    access_log /var/log/nginx/{{ サイト名 }}_access.log;
    error_log /var/log/nginx/{{ サイト名 }}_error.log;
    
    root {{ ドキュメントルート }};
    index index.html index.php;
    
    {% if SSL対応 %}
    listen 443 ssl;
    ssl_certificate /etc/ssl/certs/{{ ドメイン名 }}.crt;
    ssl_certificate_key /etc/ssl/private/{{ ドメイン名 }}.key;
    {% endif %}
    
    {% for リダイレクト in リダイレクトリスト %}
    location {{ リダイレクト.パス }} {
        return 301 {{ リダイレクト.転送先 }};
    }
    {% endfor %}
}
```

### Playbookでの使用例

```yaml
- name: Webサーバー設定をデプロイ
  hosts: webサーバー
  vars:
    ポート: 8080
    ドメイン名: "example-site.co.jp"
    サイト名: "corporate-portal"
    ドキュメントルート: "/var/www/corporate"
    SSL対応: true
    リダイレクトリスト:
      - パス: "/old-news"
        転送先: "/news"
      - パス: "/legacy-contact"
        転送先: "/contact-us"
  
  tasks:
    - name: Nginxテンプレートを適用
      template:
        src: templates/webサーバー_設定.j2
        dest: /etc/nginx/sites-available/{{ サイト名 }}
        owner: www-data
        group: www-data
        mode: '0644'
      notify: nginx再起動
  
  handlers:
    - name: nginx再起動
      service:
        name: nginx
        state: restarted
```

## テンプレート変数のデバッグ

テンプレート内で変数の内容を確認したい場合:

```jinja
{# デバッグ用コメント #}
{{ 変数 | to_nice_json }}
```

## ベストプラクティス

1. テンプレートファイルには `.j2` 拡張子を使用する
2. 複雑なロジックはAnsible側で処理し、テンプレートはシンプルに保つ
3. デフォルト値を活用して、未定義変数によるエラーを防止する
4. 本番環境では `backup: yes` オプションを使用して既存ファイルをバックアップする
5. 適切なファイルパーミッションを設定する

## 注意点

- テンプレート内での変数名は適切な命名規則に従う
- 機密情報は vault を使用して暗号化する
- テンプレート生成後のファイルを確認するデバッグ手順を用意する
