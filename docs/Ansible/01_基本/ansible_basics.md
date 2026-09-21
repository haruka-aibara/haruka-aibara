---
marp: true
theme: default
paginate: true
math: mathjax
style: |
  section {
    font-size: 1.5em;
  }
  .mermaid {
    margin: 0 auto;
  }
---

# Ansible 基本講座
## インフラ自動化の基礎を学ぶ

---

# 目次

1. Ansibleの仕組み
2. インベントリ
3. Playbook
4. モジュール
5. ロール
6. 出力の確認方法

---

# 1. Ansibleの仕組み

## 概要
Ansibleは複数のリモートサーバーを一元管理するための自動化ツールであり、簡単な構成で強力なインフラ自動化を実現します。

## 基本構成

<div class="mermaid">
graph LR
    A[管理ノード<br/>Ansible] -->|SSH| B[ターゲット1]
    A -->|SSH| C[ターゲット2]
    A -->|SSH| D[ターゲット3]
    
    subgraph インベントリ
    E[ホスト情報]
    end
    
    subgraph Playbook
    F[タスク定義]
    end
    
    A --> E
    A --> F
</div>

### マスター（管理ノード）とターゲット（リモートホスト）
- **マスター**：Ansibleをインストールして操作する管理用サーバー
- **ターゲット**：管理対象となるリモートサーバー群（SSHで接続可能なこと）

---

# 1. Ansibleの仕組み（続き）

## 主要コンポーネント

<div class="mermaid">
graph TD
    A[Ansible] --> B[インベントリ]
    A --> C[Playbook]
    A --> D[モジュール]
    
    B --> E[ホスト情報]
    B --> F[グループ情報]
    
    C --> G[タスク]
    C --> H[ハンドラー]
    
    D --> I[標準モジュール]
    D --> J[カスタムモジュール]
</div>

1. **インベントリ**：
   - 管理対象となるサーバーの情報（IPアドレスなど）を記述したファイル
   - どのサーバーに対してメンテナンスを行うかを定義する

2. **Playbook**：
   - YAML形式で記述されたファイル
   - 各ターゲットに対して実行する操作内容を定義する
   - ソフトウェアのインストール、設定変更、ファイルコピーなどのタスクを記述

---

# 1. Ansibleの仕組み（続き）

## べき等性（Idempotence）

<div class="mermaid">
sequenceDiagram
    participant A as Ansible
    participant T as ターゲット
    
    A->>T: タスク実行
    T->>A: 現在の状態確認
    alt 変更が必要
        A->>T: 変更を適用
        T->>A: 変更完了
    else 変更不要
        A->>T: スキップ
    end
</div>

Ansibleの重要な特性である「べき等性」とは：

- 同じ操作を何度実行しても、同じ結果が得られる性質
- 例：ファイルコピーのタスクは、初回実行時にのみコピー処理が行われ、2回目以降は既にファイルが存在していればスキップされる

### べき等性のメリット
- ターゲットの状態を基準にした実行制御ができる
- 何度実行しても安全（冪等性があるため）
- 不必要な処理をスキップすることで効率的な運用が可能

---

# 2. インベントリ

## 概要
インベントリはAnsible自動化の基盤となり、管理対象ホストの定義と分類を可能にする重要な要素です。

<div class="mermaid">
graph TD
    A[インベントリ] --> B[静的インベントリ]
    A --> C[動的インベントリ]
    
    B --> D[INI形式]
    B --> E[YAML形式]
    
    C --> F[クラウド]
    C --> G[VMware]
    C --> H[その他]
    
    subgraph グループ化
    I[webservers]
    J[dbservers]
    K[appservers]
    end
    
    B --> I
    B --> J
    B --> K
</div>

## インベントリの種類

### 1. 静的インベントリ
#### INIフォーマット
```ini
[webservers]
web1.example.com
web2.example.com ansible_host=192.168.1.2

[dbservers]
db1.example.com ansible_port=2222
db2.example.com
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
```

---

# 2. インベントリ（続き）

### 2. 動的インベントリ
- クラウド環境やVMware環境など、ホストが動的に変化する環境で使用
- スクリプトを使用して最新の構成情報を自動的に取得

## インベントリのベストプラクティス

1. **適切なグループ化**: 役割や地理的位置などでホストを論理的にグループ化
2. **変数の階層化**: グループ変数とホスト変数を適切に分離
3. **動的インベントリの活用**: クラウド環境では動的インベントリを検討
4. **バージョン管理**: インベントリファイルはGitなどでバージョン管理

---

# 3. Playbook

## 概要
Playbookは、Ansibleの自動化の中核となる設定ファイルで、システム構成やアプリケーションデプロイを簡潔かつ再現性高く実行できます。

<div class="mermaid">
graph TD
    A[Playbook] --> B[Play]
    B --> C[タスク]
    B --> D[ハンドラー]
    
    C --> E[モジュール]
    C --> F[変数]
    C --> G[条件]
    
    D --> H[通知]
    D --> I[実行]
    
    subgraph 実行フロー
    J[1. タスク実行]
    K[2. 変更検知]
    L[3. ハンドラー実行]
    end
    
    C --> J
    J --> K
    K --> L
</div>

## YAMLの基礎知識

- **リスト表記**: ハイフン(`-`)を使って各要素を指定
- **ディクショナリ表記**: キーと値をコロン(`:`)で区切る
- **インデント**: 半角スペース2つでレベルを表現
- **コメント**: `#`記号で行コメントを記述
- **文字列**: 通常はクォートなしでも記述可能

---

# 3. Playbook（続き）

## Playbook基本要素

### 1. 名前（name）
```yaml
- name: Webサーバーのセットアップ
```

### 2. ホスト（hosts）
```yaml
hosts: webservers
```

### 3. タスク（tasks）
```yaml
tasks:
  - name: Nginxのインストール
    yum:
      name: nginx
      state: present
```

---

# 3. Playbook（続き）

## 実践例

```yaml
# Webサーバーセットアップ用Playbook
- name: Nginxサーバーのセットアップ
  hosts: webservers
  become: true
  
  tasks:
    - name: Nginxパッケージのインストール
      yum:
        name: nginx
        state: present
      
    - name: Nginxサービスの起動と自動起動設定
      service:
        name: nginx
        state: started
        enabled: yes
```

---

# 4. モジュール

## 概要
Ansibleモジュールは、インフラ構成管理を自動化するための中核的な構成要素であり、複雑なタスクを簡単に実行できるようにする機能単位です。

<div class="mermaid">
graph TD
    A[Ansibleモジュール] --> B[標準モジュール]
    A --> C[カスタムモジュール]
    
    B --> D[command]
    B --> E[service]
    B --> F[copy]
    B --> G[file]
    B --> H[yum/apt]
    
    C --> I[Python]
    C --> J[Ruby]
    C --> K[Go]
    C --> L[Java]
    
    subgraph モジュール実行
    M[1. パラメータ検証]
    N[2. 状態確認]
    O[3. 変更適用]
    P[4. 結果返却]
    end
    
    A --> M
    M --> N
    N --> O
    O --> P
</div>

## モジュールの種類

### 1. 標準モジュール
- Ansibleにデフォルトでインストールされる組み込みモジュール
- インストール直後から即時に利用可能

**主な標準モジュールの例：**
- **commandモジュール**: ターゲットホスト上で指定したコマンドを実行
- **serviceモジュール**: ターゲットホスト上のサービス管理
- **copyモジュール**: マスターからターゲットへのファイルコピー操作

---

# 4. モジュール（続き）

### 2. カスタムモジュール
- ユーザーが独自に作成したモジュール
- 標準モジュールでは実現できない複雑な処理を行うために作成
- Python、Ruby、Go、Javaなど様々なプログラミング言語で開発可能
- Ansible内部でPythonを使用しているため、Pythonでの開発が推奨

## モジュールの選択基準
- 基本的な操作には標準モジュールを使用
- 複雑な処理や標準モジュールでカバーできない場合はカスタムモジュールを検討
- パフォーマンスや保守性を考慮した上で最適なモジュールを選択

---

# 5. ロール

## 概要
Ansibleのロールとは、自動化タスクを整理・再利用するための設計パターンであり、インフラコードを機能単位でカプセル化する仕組みです。

<div class="mermaid">
graph TD
    A[ロール] --> B[tasks]
    A --> C[handlers]
    A --> D[templates]
    A --> E[files]
    A --> F[vars]
    A --> G[defaults]
    A --> H[meta]
    
    subgraph ロール構造
    I[1. タスク定義]
    J[2. 変数管理]
    K[3. ファイル管理]
    L[4. 依存関係]
    end
    
    B --> I
    F --> J
    E --> K
    H --> L
</div>

## ロールのメリット

1. **モジュール性の向上**: 機能ごとに独立したコード単位として管理
2. **コード品質の向上**: 集中的にテストと改善を行うことで、高品質なコンポーネントを作成
3. **チーム協業の促進**: 異なるチームメンバーが個別のロールを担当することで並行開発が可能
4. **デプロイ速度の向上**: 検証済みのロールを再利用することで新環境の構築時間を短縮

---

# 5. ロール（続き）

## ロール分割戦略

### 機能ドメイン型分割
- 例: `app_server`、`data_store`、`load_balancer` など
- システムの論理的な機能ブロックごとにロールを作成

### ライフサイクル型分割
- 例: `package_install`、`config_deploy`、`service_control` など
- ソフトウェアのライフサイクル段階に応じてロールを作成

## 実装例

```yaml
# infrastructure.yml
- name: Deploy complete application stack
  hosts:
    - production_servers
  roles:
    - frontend_platform
    - data_platform
```

---

# 6. 出力の確認方法

## 出力セクションの基本構造

<div class="mermaid">
sequenceDiagram
    participant A as Ansible
    participant T as ターゲット
    
    A->>T: PLAY開始
    Note over A,T: PLAY [webservers]
    
    loop タスク実行
        A->>T: TASK実行
        Note over A,T: TASK [Install httpd]
        T->>A: 実行結果
        Note over A,T: changed: [server-1]
    end
    
    A->>A: PLAY RECAP
    Note over A: 実行結果サマリー
</div>

### 1. PLAY セクション
```
PLAY [webservers] *****************************************************
```

### 2. TASK セクション
```
TASK [Install the latest version of httpd] ***************************
changed: [server-1]
changed: [server-2]
```

### 3. PLAY RECAP セクション
```
PLAY RECAP *********************************************************
server-1 : ok=1 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
server-2 : ok=1 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

---

# 6. 出力の確認方法（続き）

## ステータスの意味

- `ok`: 正常に終了（変更なし）
- `changed`: 正常に終了（変更あり）
- `skipped`: タスクを実行しなかった
- `failed`: エラーが発生した
- `unreachable`: 通信エラーが発生した
- `rescued`: rescueディレクティブを実行した
- `ignored`: エラーが発生したが無視した

## ヒント
- `changed=0`の場合は、すでに目的の状態が達成されていることを示します
- `failed`や`unreachable`の値が0以外の場合は、問題が発生しているので詳細を確認しましょう

---

# まとめ

<div class="mermaid">
mindmap
  root((Ansible))
    シンプルな構成
      インベントリ
      Playbook
    べき等性
      安全な実行
      効率的な運用
    モジュール性
      ロール
      再利用
    柔軟性
      標準モジュール
      カスタムモジュール
    透明性
      詳細なログ
      実行結果
</div>

Ansibleは、以下の特徴を持つ強力な自動化ツールです：

1. **シンプルな構成**: インベントリとPlaybookという直感的な設計
2. **べき等性**: 安全な繰り返し実行が可能
3. **モジュール性**: 再利用可能なロールによる効率的な管理
4. **柔軟性**: 標準モジュールとカスタムモジュールの組み合わせ
5. **透明性**: 詳細な実行結果の確認が可能

これらの特徴を活かすことで、効率的で信頼性の高いインフラ管理が実現できます。 
