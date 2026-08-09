# Ansible userモジュール講座

## 1. 概要と重要性

Ansibleのuserモジュールは、システム上のユーザーアカウントを効率的に管理するための強力なツールであり、大規模インフラの一貫したユーザー管理を実現します。

## 2. 主要概念の理論的説明

userモジュールはLinuxやUNIXシステム上でユーザーアカウントの作成・変更・削除を自動化し、冪等性を保ちながら一貫した状態管理を可能にします。

## 3. userモジュールの基本操作

### 3.1 ユーザーアカウントの作成

```yaml
- name: 新しいユーザーの作成
  user:
    name: tanaka
    comment: "田中太郎"
    uid: 1040
    group: staff
    home: /home/tanaka
    shell: /bin/bash
    password: "{{ 'secure_password' | password_hash('sha512') }}"
    state: present
```

### 3.2 ユーザーアカウントの変更

```yaml
- name: ユーザー情報の更新
  user:
    name: tanaka
    comment: "田中太郎 - 営業部"
    shell: /bin/zsh
    groups: staff,sales
    append: yes
```

### 3.3 ユーザーアカウントの削除

```yaml
- name: ユーザーの削除
  user:
    name: tanaka
    state: absent
    remove: yes
```

## 4. 実践的なユースケース

ユーザー管理を含む実践的なプレイブック例：

```yaml
---
- name: ユーザー管理プレイブック
  hosts: webservers
  become: yes
  
  vars:
    users_create:
      - name: yamada
        comment: "山田花子"
        groups: developers
      - name: suzuki
        comment: "鈴木一郎"
        groups: admin
    
    users_remove:
      - name: old_user
  
  tasks:
    - name: 開発チームユーザーの作成
      user:
        name: "{{ item.name }}"
        comment: "{{ item.comment }}"
        groups: "{{ item.groups }}"
        shell: /bin/bash
        create_home: yes
        state: present
      loop: "{{ users_create }}"
      
    - name: 退職者ユーザーの削除
      user:
        name: "{{ item.name }}"
        state: absent
        remove: yes
      loop: "{{ users_remove }}"
```

## 5. よく使用するパラメータ

| パラメータ | 説明 |
|------------|------|
| name | ユーザー名（必須） |
| state | ユーザーの状態（present, absent） |
| comment | ユーザーの説明（通常はフルネーム） |
| uid | ユーザーID番号 |
| group | プライマリグループ |
| groups | セカンダリグループ（カンマ区切り） |
| append | 既存のグループ所属を維持するか（yes/no） |
| home | ホームディレクトリのパス |
| shell | ログインシェル |
| password | 暗号化されたパスワード |
| update_password | パスワード更新ポリシー（always, on_create） |
| create_home | ホームディレクトリを作成するか（yes/no） |
| remove | ユーザー削除時にホームディレクトリも削除するか（yes/no） |
| system | システムアカウントとして作成するか（yes/no） |
| expires | アカウント有効期限（エポック時間） |
