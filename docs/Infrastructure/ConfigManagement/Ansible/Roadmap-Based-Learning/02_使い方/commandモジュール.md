# Ansible講座：commandモジュール

## 1. 概要と重要性

Ansibleのcommandモジュールは、リモートホスト上でコマンドを実行するための基本的かつ強力なツールであり、構成管理の基盤となります。

## 2. 主要概念の理論的説明

commandモジュールはシェルを使用せずに直接コマンドを実行するため、変数展開やリダイレクトなどのシェル機能は使用できませんが、セキュリティ面では優れています。

## 3. 基本的な使い方

### 3.1 基本構文

```yaml
- name: コマンドの実行例
  command: 実行したいコマンド
```

### 3.2 単純なコマンド実行

```yaml
- name: 現在のディレクトリ内容を表示
  command: ls -la
```

## 4. 応用パラメータ

### 4.1 chdir パラメータ

特定のディレクトリでコマンドを実行する場合：

```yaml
- name: 指定ディレクトリでのコマンド実行
  command: ls -la
  args:
    chdir: /var/log/nginx
```

### 4.2 creates パラメータ

ファイルが存在する場合はコマンドをスキップする：

```yaml
- name: データベースセットアップ（既存なら実行しない）
  command: /opt/tools/setup_db.sh
  args:
    creates: /var/lib/myapp/db_initialized
```

### 4.3 removes パラメータ

ファイルが存在しない場合にコマンドをスキップする：

```yaml
- name: 一時ファイルの削除
  command: rm /tmp/temp_data.tmp
  args:
    removes: /tmp/temp_data.tmp
```

## 5. 戻り値の取得と利用

### 5.1 コマンド結果の保存

```yaml
- name: カーネルバージョンの取得
  command: uname -r
  register: kernel_version

- name: カーネルバージョンの表示
  debug:
    msg: "現在のカーネルバージョン: {{ kernel_version.stdout }}"
```

### 5.2 戻り値に基づく条件分岐

```yaml
- name: アプリケーションの状態確認
  command: systemctl status myservice
  register: service_status
  ignore_errors: yes

- name: アプリケーションが停止している場合に開始
  command: systemctl start myservice
  when: service_status.rc != 0
```

## 6. 注意点と制限事項

### 6.1 シェル機能の制限

commandモジュールでは以下のシェル機能が使用できません：
- パイプ (`|`)
- リダイレクト (`>`, `>>`, `<`)
- 環境変数の展開（`$HOME`など）
- ワイルドカード（`*`）の展開

これらの機能が必要な場合は、shellモジュールの使用を検討してください。

### 6.2 冪等性の欠如

commandモジュールはデフォルトで冪等性を持ちません。毎回コマンドが実行されるため、以下のような回避策を検討してください：

- `creates`/`removes`パラメータの使用
- `changed_when`ディレクティブの追加
- 状態を確認してから実行する条件分岐

```yaml
- name: データインポート（実行済みなら実行しない）
  command: /opt/scripts/import_data.sh
  args:
    creates: /var/lib/app/data_imported.flag
  changed_when: false
```

## 7. 実践例：アプリケーションデプロイメント

### 7.1 アプリケーションのビルドとデプロイ

```yaml
- name: ソースコードの取得状態確認
  command: ls -la /opt/myapp/source
  register: source_status
  changed_when: false

- name: アプリケーションのビルド
  command: make build
  args:
    chdir: /opt/myapp/source
  when: source_status.rc == 0

- name: デプロイフラグ作成
  command: touch /opt/myapp/deployed.flag
  args:
    creates: /opt/myapp/deployed.flag
```

## 8. まとめ

commandモジュールは単純なコマンド実行に最適ですが、シェル機能が不要で、冪等性を考慮した実装が必要な場合に最も効果的です。シェル機能が必要な場合はshellモジュールを、ファイル操作にはcopy/fileモジュールを、パッケージ管理にはそれぞれのパッケージマネージャー用モジュールを検討するなど、適材適所で使い分けることが重要です。
