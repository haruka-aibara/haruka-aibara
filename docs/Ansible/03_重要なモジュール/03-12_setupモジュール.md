# Ansibleのsetupモジュール

## 概要と重要性
setupモジュールはAnsibleのファクト収集の中核として、対象ホストの様々なシステム情報を自動的に取得し、Playbookでの条件分岐や変数として利用できる基盤を提供します。

## 主要概念
setupモジュールは実行時に対象ホストのシステム情報（ファクト）を収集し、ansible_factという変数として自動的に保存します。

## setupモジュールの基本使用法

単独で実行する場合は、以下のようにコマンドラインから直接実行できます：

```bash
ansible ターゲットホスト -m setup
```

この実行により、対象ホストの全てのファクト情報が収集されます。

## gather_subsetパラメータとhardware

setupモジュールでは`gather_subset`パラメータを使用して、収集する情報の範囲を制限できます。特に`hardware`サブセットは、物理的なハードウェア情報に焦点を当てます。

### hardwareサブセットの使用例

```yaml
# hardware_info.yml
---
- name: ハードウェア情報の収集
  hosts: webサーバー
  gather_facts: true
  tasks:
    - name: ハードウェア情報のみ収集
      setup:
        gather_subset:
          - hardware

    - name: CPUコア数を表示
      debug:
        msg: "このサーバーには{{ ansible_processor_cores }}コアのCPUがあります"

    - name: メモリ情報を表示
      debug:
        var: ansible_memory_mb.real
```

このPlaybookを実行すると、対象ホストのハードウェア関連情報のみが収集され、CPUコア数とメモリ情報が表示されます。

### hardwareサブセットで取得できる主な情報

hardwareサブセットでは以下のような情報が取得できます：

- `ansible_processor`: CPU情報
- `ansible_processor_cores`: CPUコア数
- `ansible_processor_count`: 物理プロセッサ数
- `ansible_memory_mb`: メモリ情報（MB単位）
- `ansible_devices`: ストレージデバイス情報
- `ansible_interfaces`: ネットワークインターフェース一覧

### 実践的な使用例

異なるハードウェア構成を持つサーバーに対して、スペックに応じた設定を適用する場合：

```yaml
# リソース最適化プレイブック: optimize_resources.yml
---
- name: サーバーリソースに基づいた最適化
  hosts: データベースサーバー
  gather_facts: true
  tasks:
    - name: ハードウェア情報収集
      setup:
        gather_subset:
          - hardware

    - name: 高メモリサーバー向け設定
      template:
        src: high_memory_db.conf.j2
        dest: /etc/my_database/config.conf
      when: ansible_memory_mb.real.total > 16000

    - name: 標準サーバー向け設定
      template:
        src: standard_db.conf.j2
        dest: /etc/my_database/config.conf
      when: ansible_memory_mb.real.total <= 16000
```

このPlaybookでは、メモリが16GB以上のサーバーとそれ以下のサーバーで異なるデータベース設定を適用しています。

## まとめ

setupモジュールの`gather_subset`パラメータと`hardware`オプションを使うことで、対象ホストのハードウェア情報に絞って効率的にデータを収集できます。これにより、サーバーの物理的な特性に基づいた柔軟な自動化が可能になります。
