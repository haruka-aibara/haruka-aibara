# Ansible lineinfileモジュール講座

## 1. 概要と重要性

lineinfileモジュールは、ファイル内の特定の行を追加、変更、削除することができる強力なツールで、設定ファイルの部分的な修正に最適です。

## 2. 基本概念

lineinfileモジュールは正規表現を用いてファイル内の行を検索し、その行を置換または新しい行を挿入することができます。

## 3. 基本的な使い方

```yaml
- name: IPアドレスの変更
  lineinfile:
    path: /etc/network/interfaces
    regexp: '^address'
    line: 'address 192.168.1.200'
```

このタスクは `/etc/network/interfaces` ファイル内で「address」で始まる行を検索し、それを「address 192.168.1.200」に置き換えます。

## 4. 主要なパラメータ

- `path`: 操作対象のファイルパス（必須）
- `regexp`: 検索する行のパターン（正規表現）
- `line`: 挿入または置換する行の内容
- `state`: present（デフォルト）またはabsent（行を削除）
- `insertafter/insertbefore`: 指定したパターンの後/前に行を挿入

## 5. 実践例

### 例1: hostsファイルにエントリを追加

```yaml
- name: webサーバーのhostsエントリ追加
  lineinfile:
    path: /etc/hosts
    line: '192.168.10.25 webserver.example.local'
```

### 例2: コメント行の追加

```yaml
- name: Apache設定にコメントを追加
  lineinfile:
    path: /etc/httpd/conf/httpd.conf
    insertbefore: '^ServerName'
    line: '# このServerNameはメインサイト用です'
```

### 例3: 行の削除

```yaml
- name: 特定のユーザーをsudoersから削除
  lineinfile:
    path: /etc/sudoers
    regexp: '^testuser'
    state: absent
```

## 6. 注意点

- `regexp`パラメータを慎重に設計しないと、意図しない行が変更される可能性があります
- 複数行の変更には向いておらず（blockinfileの方が適切）、単一行の操作に最適です
- バックアップを取ることをお勧めします（`backup: yes`オプション）

## 7. よくある使用シナリオ

- 設定ファイルの特定パラメータ変更
- `/etc/hosts`ファイルへのエントリ追加
- sshd_configなどのセキュリティ設定変更
- 環境変数の追加・変更（.bashrcなど）

## 8. まとめ

lineinfileモジュールは、設定ファイルの単一行を効率的に管理するための強力なツールです。正規表現の知識と組み合わせることで、システム設定の自動化における柔軟性が大幅に向上します。
