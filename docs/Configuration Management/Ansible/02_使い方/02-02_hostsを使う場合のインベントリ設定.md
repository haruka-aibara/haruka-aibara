# Ansible講座: /etc/ansible/hostsを使用したインベントリ設定

## 1. インベントリの概要と重要性

Ansibleのインベントリは管理対象となるホストグループを定義する設定で、自動化の基盤となる重要な要素です。

## 2. /etc/ansible/hostsファイルについて

`/etc/ansible/hosts`はAnsibleのデフォルトインベントリファイルで、管理対象ホストをグループ化して定義します。

## 3. 基本的なホスト定義

```ini
# 基本的なホスト定義（IPアドレスまたはホスト名）
webサーバー1.example.jp
192.168.10.50
```

## 4. グループ定義

```ini
# サーバーをグループ化する
[ウェブサーバー]
web-tokyo01.example.jp
web-tokyo02.example.jp

[データベース]
db-primary.example.jp
db-replica.example.jp
```

## 5. グループのネスト化

```ini
# グループを階層化する
[アプリサーバー]
app01.example.jp
app02.example.jp

[ステージング:children]
ウェブサーバー
データベース

[本番環境:children]
ウェブサーバー
データベース
アプリサーバー
```

## 6. ホスト変数の定義

```ini
# ホスト単位の変数設定
web-tokyo01.example.jp アクセスポート=8080 最大接続数=100

# 複数行での記述も可能
web-tokyo02.example.jp アクセスポート=8080
                     最大接続数=200
```

## 7. グループ変数の定義

```ini
[ウェブサーバー]
web-tokyo01.example.jp
web-tokyo02.example.jp

[ウェブサーバー:vars]
http_port=80
https_port=443
```

## 8. 接続パラメータの設定

```ini
[リモート管理]
管理サーバー01 ansible_host=192.168.20.10 ansible_user=管理者 ansible_port=2222
バックアップサーバー ansible_connection=ssh ansible_ssh_private_key_file=/home/管理者/.ssh/特殊鍵.pem
```

## 9. 使用例

```bash
# 特定グループに対して実行
ansible ウェブサーバー -m ping

# 複数グループに対して実行
ansible 'ウェブサーバー:データベース' -m ping

# グループパターンで実行
ansible '本番環境:!アプリサーバー' -m ping  # 本番環境からアプリサーバーを除外
```

## 10. 注意点

- `/etc/ansible/hosts`ファイルはデフォルトパスですが、`-i`オプションで別のインベントリファイルを指定できます
- 大規模環境では、ディレクトリベースのインベントリや動的インベントリの使用を検討しましょう
- ホスト名に特殊文字が含まれる場合は引用符で囲みます
