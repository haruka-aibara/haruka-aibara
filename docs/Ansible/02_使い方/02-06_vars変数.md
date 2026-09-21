# Ansible講座：変数(vars)の活用

## 変数の概要と重要性

Ansibleの変数(vars)はプレイブックを柔軟かつ再利用可能にする鍵となる機能で、環境ごとの設定値や動的なデータを簡単に管理できます。

## 変数の基本概念

変数はタスクやテンプレートで利用できる値を保持し、複数の環境や状況に合わせてコードを変更することなく適応させることができます。

## 変数の定義方法

### 1. プレイブック内での定義

```yaml
---
- hosts: webサーバー
  vars:
    http_port: 8080
    max_connections: 100
  tasks:
    - name: nginxの設定ファイルをテンプレート化
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      vars:
        worker_processes: 4
```

### 2. 変数ファイルの利用

別ファイルで変数を定義し、`vars_files`で読み込む方法:

```yaml
# main_playbook.yml
---
- hosts: データベースサーバー
  vars_files:
    - ./変数/db_設定.yml
  tasks:
    - name: MySQLの設定
      template:
        src: my.cnf.j2
        dest: /etc/mysql/my.cnf
```

```yaml
# ./変数/db_設定.yml
---
mysql_port: 3306
mysql_max_connections: 150
mysql_buffer_pool_size: 4G
```

### 3. インベントリ変数

ホストやグループ単位で変数を定義する方法:

```ini
# inventory.ini
[webサーバー]
web01.example.jp http_port=80 max_clients=200
web02.example.jp http_port=8080 max_clients=100

[webサーバー:vars]
domain=example.jp
admin_email=admin@example.jp
```

### 4. グループ変数とホスト変数

ディレクトリ構造を使った変数管理:

```
inventories/
├── 本番環境/
│   ├── hosts
│   ├── group_vars/
│   │   ├── all.yml
│   │   └── webサーバー.yml
│   └── host_vars/
│       ├── web01.example.jp.yml
│       └── db01.example.jp.yml
└── 開発環境/
    ├── hosts
    └── group_vars/
        └── all.yml
```

## 変数の優先順位

変数には優先順位があり、より具体的な場所で定義された変数が優先されます:

1. コマンドライン変数 (最高優先)
2. タスクレベルの変数
3. プレイレベルの変数
4. ホスト変数 (host_vars)
5. グループ変数 (group_vars)
6. インベントリ変数
7. ロール変数 (最低優先)

## 変数の活用例

### テンプレートでの利用

Jinja2テンプレートで変数を利用:

```jinja
# nginx.conf.j2
worker_processes {{ worker_processes }};

http {
    server {
        listen {{ http_port }};
        server_name {{ domain }};
        
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
        }
    }
}
```

### 条件分岐での利用

```yaml
- name: デバッグモードを設定
  template:
    src: app.conf.j2
    dest: /etc/app/app.conf
  when: 環境タイプ == "開発"
```

### ループでの利用

```yaml
- name: 複数のパッケージをインストール
  apt:
    name: "{{ item }}"
    state: present
  loop: "{{ インストールパッケージ }}"
```

## 便利な変数操作

### デフォルト値の設定

```yaml
# 変数が未定義の場合にデフォルト値を使用
effective_port: "{{ http_port | default(80) }}"
```

### 変数の結合と加工

```yaml
# 文字列の結合
full_domain: "{{ サービス名 }}.{{ domain }}"

# 数値計算
total_memory: "{{ (available_memory * 0.8) | int }}MB"
```

## まとめ

Ansibleの変数システムを活用することで、環境ごとの差異を吸収し、再利用性の高いプレイブックを作成できます。変数の定義場所や優先順位を理解することで、効率的な自動化が実現できます。
