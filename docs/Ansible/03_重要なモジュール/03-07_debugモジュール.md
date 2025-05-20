# Ansible debugモジュール講座

## 1. debugモジュールの概要と重要性

debugモジュールは、Ansibleのプレイブック実行中に変数の値や式の結果を確認するための強力な診断ツールです。

## 2. 主要概念の理論的説明

debugモジュールは主に「msg」パラメータと「var」パラメータを使用して、実行時の情報を表示します。

## 3. 基本的な使い方

### 3.1 メッセージの表示

```yaml
- name: 単純なメッセージを表示する
  debug:
    msg: "これはデバッグメッセージです"
```

### 3.2 変数の表示

```yaml
- name: 変数の内容を表示する
  debug:
    var: システム変数
```

### 3.3 verbosityレベルの設定

```yaml
- name: 詳細レベル2でのみ表示するデバッグ情報
  debug:
    msg: "詳細な情報がここに表示されます"
    verbosity: 2
```

## 4. 実践例

### 4.1 変数の値を確認する

```yaml
---
- name: 変数デバッグのデモ
  hosts: localhost
  vars:
    動作環境: "テスト環境"
    サーバー情報:
      名前: "検証サーバー"
      IPアドレス: "192.168.56.10"
  
  tasks:
    - name: 単純な変数を表示
      debug:
        var: 動作環境
    
    - name: 辞書型変数の特定の要素を表示
      debug:
        var: サーバー情報.名前
```

### 4.2 条件付きデバッグ

```yaml
---
- name: 条件付きデバッグのデモ
  hosts: webservers
  vars:
    アプリケーション_ステータス: "稼働中"
  
  tasks:
    - name: サーバーの状態を確認
      shell: systemctl status nginx
      register: サービス_状態
      ignore_errors: yes
    
    - name: エラーが発生した場合にデバッグ情報を表示
      debug:
        msg: "Nginxサービスに問題が発生しました: {{ サービス_状態.stderr }}"
      when: サービス_状態.rc != 0
```

### 4.3 複雑な式の評価

```yaml
---
- name: 式の評価デモ
  hosts: localhost
  vars:
    商品一覧:
      - 名前: "りんご"
        価格: 100
        在庫: 50
      - 名前: "みかん"
        価格: 80
        在庫: 30
      - 名前: "バナナ"
        価格: 120
        在庫: 20
  
  tasks:
    - name: 在庫合計の計算と表示
      debug:
        msg: "総在庫数: {{ 商品一覧 | map(attribute='在庫') | sum }}"
    
    - name: 特定の条件に一致する商品を検索して表示
      debug:
        msg: "価格が100円以上の商品: {{ 商品一覧 | selectattr('価格', '>=', 100) | map(attribute='名前') | list }}"
```

## 5. トラブルシューティングのテクニック

### 5.1 実行中のファクト情報の確認

```yaml
- name: システム情報を表示
  debug:
    var: ansible_facts
    verbosity: 1
```

### 5.2 登録変数の構造確認

```yaml
- name: コマンド実行結果を取得
  command: df -h
  register: ディスク情報
  
- name: 登録変数の完全な構造を表示
  debug:
    var: ディスク情報
  
- name: 標準出力のみを表示
  debug:
    var: ディスク情報.stdout_lines
```

### 5.3 JSONデータの整形表示

```yaml
- name: API呼び出し
  uri:
    url: https://api.example.com/data
    return_content: yes
  register: api_結果
  
- name: JSON応答を整形して表示
  debug:
    msg: "{{ api_結果.json | to_nice_json }}"
```

## 6. ベストプラクティス

- デバッグ情報は適切なverbosityレベルで設定し、通常の実行時には表示されないようにする
- 機密情報をデバッグ出力に含めない
- 大きなデータ構造を表示する場合は、必要な部分だけをフィルタリングする
- プロダクション環境では不要なデバッグタスクを無効化するか削除する

## 7. まとめ

debugモジュールは、Ansibleプレイブックの開発とトラブルシューティングにおいて不可欠なツールです。変数の内容確認、条件式のテスト、実行状態の診断に活用することで、プレイブックの品質向上と問題解決の迅速化が図れます。
