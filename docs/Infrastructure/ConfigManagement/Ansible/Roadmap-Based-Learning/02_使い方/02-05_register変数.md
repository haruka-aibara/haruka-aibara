# Ansible講座：register変数の活用

## 概要と重要性
registerはタスクの実行結果を変数として保存し、後続のタスクで活用するための強力な機能です。

## 主要概念の理論的説明
register変数はタスクの出力（標準出力、エラー出力、終了コードなど）を辞書形式で格納し、条件分岐や後続タスクでの参照を可能にします。

## registerの基本構文

```yaml
- name: コマンドを実行する
  command: ls -la /var/log
  register: log_files_info
  
- name: 取得した情報を表示する
  debug:
    var: log_files_info
```

## register変数の主な属性

register変数には以下の主な属性が含まれます：

- `stdout`: コマンドの標準出力（文字列）
- `stderr`: コマンドの標準エラー出力（文字列）
- `stdout_lines`: 標準出力を行ごとに分割したリスト
- `stderr_lines`: 標準エラー出力を行ごとに分割したリスト
- `rc`: コマンドの終了コード（0は成功、それ以外は失敗を示す）
- `changed`: タスクが変更を加えたかどうか（ブール値）
- `failed`: タスクが失敗したかどうか（ブール値）

## 実践例

### 例1: ファイル存在確認と条件分岐

```yaml
- name: 設定ファイルの存在確認
  stat:
    path: /etc/ntp_custom.conf
  register: ntp_config_status

- name: NTPサービスの再起動（設定ファイルが存在する場合のみ）
  service:
    name: ntp
    state: restarted
  when: ntp_config_status.stat.exists
```

### 例2: コマンド結果の処理

```yaml
- name: 実行中のプロセスを確認
  shell: ps aux | grep httpd
  register: process_result
  changed_when: false  # コマンド自体は変更とみなさない
  failed_when: false   # grepの結果に関わらず失敗とみなさない

- name: HTTPDプロセスが実行中か確認
  debug:
    msg: "HTTPDが実行中です"
  when: process_result.stdout_lines | length > 0
```

### 例3: 複数のホストからの情報収集

```yaml
- name: ディスク使用量を確認
  shell: df -h | grep '/dev/sda1'
  register: disk_usage
  changed_when: false

- name: 結果を一覧表示用に保存
  set_fact:
    host_disk_info: "{{ ansible_hostname }}: {{ disk_usage.stdout }}"

- name: 全サーバーのディスク使用状況を表示
  debug:
    msg: "{{ hostvars[item]['host_disk_info'] }}"
  with_items: "{{ groups['all'] }}"
  run_once: true
```

## 応用テクニック

### JSON形式の出力処理

```yaml
- name: API呼び出し
  uri:
    url: https://api.example.com/status
    return_content: yes
  register: api_response

- name: APIレスポンスのステータスを表示
  debug:
    msg: "サービスステータス: {{ api_response.json.status }}"
  when: api_response.status == 200
```

### register変数と条件式の組み合わせ

```yaml
- name: ユーザーが存在するか確認
  command: id tech_user
  register: user_check
  failed_when: false
  changed_when: false

- name: ユーザーが存在しない場合は作成
  user:
    name: tech_user
    state: present
  when: user_check.rc != 0
```

### ループとregisterの組み合わせ

```yaml
- name: 複数のサービスステータス確認
  service_facts:
  register: service_status

- name: 必須サービスの状態確認
  debug:
    msg: "{{ item }}は{{ 'アクティブ' if service_status.ansible_facts.services[item]['state'] == 'running' else '停止中' }}です"
  loop:
    - 'sshd.service'
    - 'nginx.service'
    - 'mysql.service'
  when: item in service_status.ansible_facts.services
```

## register変数使用時の注意点

1. **変数のスコープ**: register変数はタスクが実行されたホストでのみ有効です
2. **冪等性への配慮**: `changed_when`と`failed_when`を適切に設定しましょう
3. **大量データの扱い**: 巨大な出力を保存する場合はメモリ消費に注意しましょう
4. **エラーハンドリング**: `ignore_errors`と組み合わせて柔軟なエラー処理が可能です

## まとめ

register変数はAnsibleプレイブックの柔軟性と表現力を大幅に向上させる重要な機能です。タスクの結果を保存し、その情報に基づいて動的に振る舞いを変更することで、より賢く効率的な自動化が実現できます。
