# Ansible fileモジュール講座

## 1. fileモジュールの概要と重要性

Ansibleのfileモジュールは、リモートホスト上でのファイルやディレクトリの作成・変更・削除などの基本的なファイル操作を簡単に自動化できる重要なモジュールです。

## 2. fileモジュールの基本概念

fileモジュールは、パーミッション設定、所有者変更、ファイル/ディレクトリの存在確認など、Linuxファイルシステムの基本操作をべき等性（何度実行しても同じ結果になる）を保ちながら実行できます。

## 3. 基本的な使い方

### 3.1 ファイルの作成

```yaml
- name: テキストファイルの作成
  file:
    path: /home/admin/メモ.txt
    state: touch
    mode: '0644'
```

### 3.2 ディレクトリの作成

```yaml
- name: プロジェクトディレクトリの作成
  file:
    path: /opt/webapp_data
    state: directory
    mode: '0755'
    owner: webapp
    group: webapp
```

### 3.3 シンボリックリンクの作成

```yaml
- name: 設定ファイルへのシンボリックリンク作成
  file:
    src: /etc/nginx/sites-available/example-site.conf
    dest: /etc/nginx/sites-enabled/example-site.conf
    state: link
```

### 3.4 ファイル/ディレクトリの削除

```yaml
- name: 一時ファイルの削除
  file:
    path: /tmp/作業ログ.txt
    state: absent
```

## 4. 主要パラメータ

| パラメータ | 説明 | 例 |
|------------|------|-----|
| path (dest) | 操作対象のパス | `/var/log/app_logs` |
| state | ファイルの状態 | `touch`, `directory`, `link`, `absent` など |
| mode | パーミッション | `'0644'`, `'u+x'` |
| owner | 所有ユーザー | `nginx` |
| group | 所有グループ | `webadmin` |
| src | シンボリックリンクの元ファイル | `/etc/original.conf` |

## 5. 実践例：ウェブアプリケーションのディレクトリ構造作成

```yaml
- name: ウェブアプリディレクトリ構造作成
  hosts: webservers
  become: yes
  tasks:
    - name: アプリケーションディレクトリ作成
      file:
        path: "{{ item.path }}"
        state: directory
        mode: "{{ item.mode }}"
        owner: webuser
        group: webdev
      loop:
        - { path: '/var/www/shopapp', mode: '0755' }
        - { path: '/var/www/shopapp/public', mode: '0755' }
        - { path: '/var/www/shopapp/logs', mode: '0775' }
        - { path: '/var/www/shopapp/temp', mode: '0775' }
        - { path: '/var/www/shopapp/config', mode: '0750' }

    - name: 必要なファイルの作成
      file:
        path: "{{ item }}"
        state: touch
        mode: '0644'
        owner: webuser
        group: webdev
      loop:
        - '/var/www/shopapp/config/app.cfg'
        - '/var/www/shopapp/logs/access.log'
        - '/var/www/shopapp/logs/error.log'
```

## 6. 応用テクニック

### 6.1 再帰的なパーミッション設定

```yaml
- name: 再帰的にディレクトリのパーミッションを設定
  file:
    path: /opt/データ保管庫
    state: directory
    mode: '0755'
    owner: datauser
    group: datagroup
    recurse: yes
```

### 6.2 条件に基づくファイル操作

```yaml
- name: 環境変数に基づいてログファイルを作成
  file:
    path: "/var/log/{{ env_name }}_application.log"
    state: touch
    mode: '0644'
  when: env_name is defined
```

## 7. よくあるエラーと対処法

1. **パーミッションエラー**：
   - 症状：`Permission denied`
   - 対処：`become: yes` を追加するか、ファイル操作の権限を確認

2. **パスが存在しない**：
   - 症状：`Destination directory /path/to/dir does not exist`
   - 対処：親ディレクトリを先に作成するタスクを追加

3. **シンボリックリンクのソースが存在しない**：
   - 症状：`Source file does not exist`
   - 対処：リンク元のファイルが存在することを確認

## 8. まとめ

fileモジュールは、Ansibleによるインフラ自動化の基本的な構成要素で、ファイルシステム操作を効率的に行うことができます。パーミッションや所有者の設定、ファイル/ディレクトリの存在確認など、多くのファイルシステム操作を簡潔なYAML構文で記述できるため、構成管理の強力なツールとなります。
