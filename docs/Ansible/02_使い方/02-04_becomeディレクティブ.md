# Ansible becomeディレクティブ

## 概要と重要性
becomeディレクティブはAnsibleで権限昇格を行うための重要な機能で、一般ユーザーから管理者権限へ切り替えて特権操作を実行できます。

## 理論的説明
becomeはsudoやsu、runas等の権限昇格メカニズムを抽象化し、異なるOSでも一貫した方法で特権実行を可能にします。

## 基本的な使い方

### Playbookでのbecomeディレクティブの使用例

```yaml
---
- name: パッケージインストールの例
  hosts: webservers
  become: true  # このプレイブック全体でroot権限を使用

  tasks:
    - name: nginxをインストール
      package:
        name: nginx
        state: present
```

### タスクレベルでのbecomeの適用

```yaml
---
- name: 選択的な権限昇格の例
  hosts: appservers
  become: false  # デフォルトでは権限昇格しない

  tasks:
    - name: アプリケーションディレクトリ作成
      file:
        path: /app/data
        state: directory
      become: true  # このタスクだけ権限昇格
      
    - name: アプリケーションファイル配置
      copy:
        src: app.conf
        dest: /home/appuser/config/
      # 権限昇格なしで実行
```

## becomeの関連パラメータ

### become_user

特定のユーザーとして実行する場合に使用します：

```yaml
- name: データベース設定を実行
  hosts: dbservers
  become: true
  become_user: postgres  # postgresユーザーとして実行

  tasks:
    - name: データベース作成
      postgresql_db:
        name: projectdb
        state: present
```

### become_method

権限昇格の方法を指定します：

```yaml
- name: Windows管理タスク
  hosts: winservers
  become: true
  become_method: runas  # Windowsではrunasを使用
  become_user: administrator
  
  tasks:
    - name: サービス再起動
      win_service:
        name: spooler
        state: restarted
```

一般的なbecome_methodの値：
- sudo (デフォルト・Linux/Unix)
- su (Linux/Unix)
- pbrun (PowerBroker)
- pfexec (Solaris)
- runas (Windows)
- doas (OpenBSD)

### become_flags

権限昇格コマンドに追加のフラグを渡す場合に使用します：

```yaml
- name: 特殊なsudo設定を使用
  hosts: secureservers
  become: true
  become_flags: '-H -S -n'  # sudoに追加フラグを渡す
  
  tasks:
    - name: セキュリティ更新適用
      yum:
        name: '*'
        security: yes
        update_only: yes
```

## インベントリでのbecome設定

グループやホスト単位で権限昇格設定をデフォルト値として指定できます：

```ini
# inventory.ini
[webservers]
web1.example.com
web2.example.com

[webservers:vars]
ansible_become=true
ansible_become_user=webadmin

[dbservers]
db1.example.com
db2.example.com

[dbservers:vars]
ansible_become=true
ansible_become_user=dbadmin
ansible_become_method=sudo
```

## コマンドラインでの指定

Ad-hocコマンドでbecomeを使用する例：

```bash
# sudoを使って全サーバーでサービス再起動
ansible webservers -m service -a "name=nginx state=restarted" --become

# 特定のユーザーとして実行
ansible dbservers -m postgresql_db -a "name=testdb state=present" --become --become-user=postgres
```

## セキュリティ上の注意点

- プレイブック内にパスワードを平文で記述しないこと
- `--ask-become-pass`または`-K`オプションを使用してパスワードを安全に入力
- vaultを使った認証情報の暗号化を検討

```bash
# パスワード入力を促す
ansible-playbook deploy.yml --become -K
```

## トラブルシューティング

### よくあるエラーと解決法

1. **権限エラー**:
```
"Failed to set permissions on the temporary files Ansible needs to create when becoming an unprivileged user"
```
- 解決策: `/tmp`ディレクトリのパーミッションを確認し、`ansible_remote_tmp`変数の設定を検討

2. **sudoパスワード要求との不一致**:
```
"Missing sudo password"
```
- 解決策: `-K`オプションでパスワード入力を有効にするか、NOPASSWD設定を確認

3. **become_userが存在しない**:
```
"Failed to set permissions... become_user does not exist"
```
- 解決策: 指定したユーザーが対象ホストに存在することを確認

## 実践的なユースケース

### 複数のユーザー切り替え

```yaml
---
- name: 複数ユーザーでの操作例
  hosts: multiserver
  become: false

  tasks:
    - name: アプリケーションデプロイ（appuserとして）
      copy:
        src: /local/app/
        dest: /opt/application/
      become: true
      become_user: appuser
      
    - name: データベース更新（dbuserとして）
      shell: /opt/scripts/update_db.sh
      become: true
      become_user: dbuser
      
    - name: ログローテーション設定（rootとして）
      template:
        src: logrotate.j2
        dest: /etc/logrotate.d/applog
      become: true
```

## まとめ

- becomeディレクティブは細かい粒度で権限昇格を制御できる
- セキュリティを考慮した設計が重要
- 様々なレベル（プレイブック、タスク、インベントリ）で設定可能
