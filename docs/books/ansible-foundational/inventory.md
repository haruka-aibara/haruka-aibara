---
title: "Ansibleのインベントリ基礎"
slug: "inventory"
---

# Ansibleのインベントリ基礎

## 概要
インベントリはAnsible自動化の基盤となり、管理対象ホストの定義と分類を可能にする重要な要素です。

## インベントリとは
インベントリとは、Ansibleが操作する対象となるホストやグループを定義したファイルで、自動化タスクの実行先を特定します。

## インベントリの種類

### 1. 静的インベントリ
静的インベントリは手動で作成・管理されるファイルで、以下の形式が一般的です：

#### INIフォーマット
```ini
[webservers]
web1.example.com
web2.example.com ansible_host=192.168.1.2

[dbservers]
db1.example.com ansible_port=2222
db2.example.com

[tokyo:children]
webservers
```

#### YAMLフォーマット
```yaml
all:
  children:
    webservers:
      hosts:
        web1.example.com:
        web2.example.com:
          ansible_host: 192.168.1.2
    dbservers:
      hosts:
        db1.example.com:
          ansible_port: 2222
        db2.example.com:
    tokyo:
      children:
        webservers:
```

### 2. 動的インベントリ
クラウド環境やVMware環境など、ホストが動的に変化する環境では、スクリプトを使用して最新の構成情報を自動的に取得できます。

## インベントリの使用

### 基本的な使用方法
```bash
# デフォルトのインベントリファイル(/etc/ansible/hosts)を使用
ansible all -m ping

# 特定のインベントリファイルを指定
ansible -i inventory.ini all -m ping
```

### インベントリ変数の設定
ホスト単位やグループ単位で変数を設定できます：

```ini
[webservers]
web1.example.com http_port=80
web2.example.com http_port=8080

[webservers:vars]
ansible_user=deploy
```

## インベントリのベストプラクティス

1. **適切なグループ化**: 役割や地理的位置などでホストを論理的にグループ化
2. **変数の階層化**: グループ変数とホスト変数を適切に分離
3. **動的インベントリの活用**: クラウド環境では動的インベントリを検討
4. **バージョン管理**: インベントリファイルはGitなどでバージョン管理

