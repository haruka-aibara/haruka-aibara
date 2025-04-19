# DevOpsエンジニア ロードマップ：学習順序と説明

***

## 学習順序と理由

このロードマップは、DevOpsエンジニアとして必要なスキルを効率的に身につけるための順序で構成されています。基礎的な知識から徐々に応用的なツールやプラクティスへと進む構造になっています。

## 1. プログラミング言語
### Python
**概要**: DevOpsの自動化スクリプト作成、ツール開発に広く使われる汎用プログラミング言語。読みやすい構文と豊富なライブラリが特徴。

**この段階で学ぶ理由**: 
- DevOpsの多くのツールがPythonで書かれている（Ansible等）
- 自動化スクリプトの作成に最適
- 入門しやすく、基本的なプログラミング概念を学ぶのに適している
- 後続のDevOpsツールをカスタマイズする際に必要になる

**教材**: https://www.udemy.com/course/python-beginner

こちらにまとめてます
https://github.com/haruka-aibara/tech-learnings/tree/main/Foundations/Programming%20Language/Python/Roadmap-Based-Learning

## 2. オペレーティングシステム
### Linux (Ubuntu/Debian)
**概要**: オープンソースのOS。多くのサーバー環境で使用されており、DevOpsの基盤となるシステム。

**この段階で学ぶ理由**:
- 多くのサーバーやコンテナがLinuxベースで動作している
- コマンドラインの基本操作を習得するために必須
- 後続のツール（Docker、Kubernetes等）はLinux環境での使用が前提
- インフラの自動化を理解するための基礎知識となる

**教材**: 
https://roadmap.sh/linux　の各リンクが良さそうです

こちらにまとめてます
https://github.com/haruka-aibara/tech-learnings/tree/main/Foundations/Operating%20System/Linux/Roadmap-Based-Learning

## 3. ターミナル知識
### Bash、エディタ、モニタリングツール
**概要**: コマンドラインでの操作技術。スクリプト作成、テキスト編集、システム監視などの基本スキル。

**この段階で学ぶ理由**:
- DevOpsの多くの作業はコマンドラインから行われる
- 自動化スクリプトの作成・実行に必須
- サーバー環境でのトラブルシューティングに必要
- リモートサーバーへのアクセスや管理に不可欠

**教材**: 
- Bash: https://www.youtube.com/watch?v=tK9Oc6AEnR4
- Vim: https://www.youtube.com/watch?v=RZ4p-saaQkc
- Nano: https://www.youtube.com/watch?v=DLeATFgGM-A
- Emacs: https://www.youtube.com/watch?v=48JlgiBpw_I
- プロセスモニタリング: https://www.youtube.com/watch?v=n9nZ1ellaV0

こちらにまとめてます
未作成　roadmap.sh なし

## 4. バージョン管理システム
### Git
**概要**: 分散型バージョン管理システム。コードの変更履歴を追跡し、複数人での開発を可能にする。

**この段階で学ぶ理由**:
- コード変更の追跡と管理はDevOpsの基本原則
- CI/CDパイプラインの基盤となる
- チーム開発の標準ツール
- Infrastructure as Code（IaC）の管理に必須

**教材**: 
Udemy にはあまりしっくりくる教材見つからず

## 5. VCSホスティング
### GitHub
**概要**: Gitリポジトリのホスティングサービス。コード共有、イシュー管理、CI/CD機能などを提供。

**この段階で学ぶ理由**:
- 実際のプロジェクト管理で広く使用されている
- CI/CD（GitHub Actions）との連携が容易
- Pull Requestベースの開発フローを学べる
- コードレビュープロセスを理解できる

**教材**: 
Udemy にはあまりしっくりくる教材見つからず

こちらにまとめてます（4. バージョン管理システム と同じ）
https://github.com/haruka-aibara/tech-learnings/tree/main/Version%20Control%20Systems/Git%20and%20GitHub/Roadmap-Based-Learning

## 6. コンテナ
### Docker
**概要**: アプリケーションとその依存関係をコンテナとしてパッケージ化するプラットフォーム。環境の一貫性と移植性を提供。

**この段階で学ぶ理由**:
- モダンなアプリケーション開発・デプロイの標準
- 環境の一貫性を保証し、「自分の環境では動作する」問題を解決
- Kubernetesなどのオーケストレーションツールの前提知識
- マイクロサービスアーキテクチャの実装に不可欠

**教材**: https://www.udemy.com/course/ok-docker

こちらにまとめてます
https://github.com/haruka-aibara/tech-learnings/tree/main/Infrastructure/Containers/Docker/Roadmap-Based-Learning

## 7. プロキシ・サーバー設定
### Nginx、プロキシ、ロードバランサーなど
**概要**: ネットワークトラフィックの制御、ルーティング、負荷分散などを行うコンポーネント。

**この段階で学ぶ理由**:
- 本番環境のインフラ構築に必須の知識
- セキュリティ対策の重要な部分
- スケーラブルなシステム設計の基本
- マイクロサービスアーキテクチャでの通信制御に必要

**教材**: 


こちらにまとめてます
未作成　roadmap.sh なし

## 8. ネットワークとプロトコル
### DNS、HTTP(S)、SSL/TLS、SSH
**概要**: インターネットやネットワーク通信の基本となるプロトコルと技術。

**この段階で学ぶ理由**:
- インフラストラクチャ全体を理解するための基礎
- セキュアな通信の実装に必須
- トラブルシューティングに必要な知識
- クラウドサービスの設定に関わる基本概念

こちらにまとめてます
未作成　roadmap.sh なし

## 9. クラウドプロバイダー
### AWS
**概要**: Amazon Web Services。クラウドコンピューティングサービスの最大手。様々なインフラとプラットフォームサービスを提供。

**この段階で学ぶ理由**:
- 業界標準のクラウドプラットフォーム
- インフラ構築の自動化スキルを実践できる
- スケーラブルなシステム設計を学べる
- 多様なマネージドサービスを活用したDevOpsプラクティスを実践できる

こちらにまとめてます
未作成　roadmap.sh なし

## 10. サーバーレス
### AWS Lambda
**概要**: イベント駆動型のコンピューティングサービス。サーバー管理なしでコードを実行できる。

**この段階で学ぶ理由**:
- モダンなクラウドアーキテクチャの重要な構成要素
- マイクロサービス実装の効率的な方法
- インフラ管理の負担を減らしながら自動化を実現できる
- コスト効率の高いシステム設計を学べる

こちらにまとめてます
未作成　roadmap.sh なし

## 11. プロビジョニング
### Terraform
**概要**: Infrastructure as Code（IaC）ツール。コードでインフラストラクチャを定義、プロビジョニング、管理する。

**この段階で学ぶ理由**:
- インフラの一貫性と再現性を確保するための標準ツール
- 複数のクラウドプロバイダーに対応（マルチクラウド戦略）
- バージョン管理と協調作業が可能
- 自動化されたインフラデプロイメントの基盤

**教材**: https://www.udemy.com/course/iac-with-terraform

こちらにまとめてます
https://github.com/haruka-aibara/tech-learnings/tree/main/Infrastructure/IaC/Terraform/Roadmap-Based-Learning

## 12. 構成管理
### Ansible
**概要**: サーバー構成管理ツール。YAMLベースの宣言型言語でサーバーの状態を定義し自動化する。

**この段階で学ぶ理由**:
- エージェントレスでシンプルな設計
- 既存インフラの自動化に適している
- 分かりやすいYAML構文
- 多数のサーバーの一貫した管理を実現

**教材**: https://www.udemy.com/course/aws-ansibleinfrastructure-as-code

こちらにまとめてます
未作成　roadmap.sh なし

## 13. CI/CDツール
### GitHub Actions
**概要**: GitHubに統合されたCI/CDプラットフォーム。コード変更に対する自動ビルド、テスト、デプロイを実現。

**この段階で学ぶ理由**:
- GitHubと緊密に統合されている
- シンプルなYAML構文で設定可能
- 追加インフラ不要でCI/CDを実現できる
- 豊富なマーケットプレイスアクションが利用可能

**教材**: https://www.udemy.com/course/github-actions-the-complete-guide

こちらにまとめてます
https://github.com/haruka-aibara/tech-learnings/tree/main/Version%20Control%20Systems/Git%20and%20GitHub/Roadmap-Based-Learning/07_GitHub%E3%83%AF%E3%83%BC%E3%82%AF%E3%83%95%E3%83%AD%E3%83%BC/07-02_GitHub%20Actions

## 14. シークレット管理
### Vault
**概要**: HashiCorpのセキュリティツール。パスワード、API鍵などの機密情報を安全に保存・アクセス管理する。

**この段階で学ぶ理由**:
- セキュアなシステム構築の重要要素
- 自動化されたシステムでの認証情報管理に必須
- コンプライアンス要件を満たすための基盤
- 動的シークレット生成などの高度な機能

**教材**: https://www.udemy.com/course/hashicorp-vault

こちらにまとめてます
未作成　roadmap.sh なし

## 15. インフラストラクチャモニタリング
### Prometheus、Grafana、Datadog
**概要**: システムとインフラのメトリクス収集、可視化、アラート管理を行うツール群。

**この段階で学ぶ理由**:
- システムの健全性と性能を把握するために必須
- 問題の早期発見と予防的対応を可能にする
- SLI/SLO/SLAの管理に必要
- データ駆動の意思決定を支援

**教材**: https://www.udemy.com/course/awsgrafanaprometheus/

こちらにまとめてます
未作成　roadmap.sh なし

## 16. ログ管理
### Splunk、Grafana Loki
**概要**: 分散システムからのログデータを集約、検索、分析するためのプラットフォーム。

**この段階で学ぶ理由**:
- 障害調査とトラブルシューティングに必須
- システム動作の可視化と理解に役立つ
- セキュリティインシデントの検出に不可欠
- コンプライアンス要件を満たすために必要

こちらにまとめてます
未作成　roadmap.sh なし

## 17. コンテナオーケストレーション
### Kubernetes、EKS
**概要**: コンテナ化されたアプリケーションのデプロイ、スケーリング、管理を自動化するプラットフォーム。

**この段階で学ぶ理由**:
- コンテナ化アプリケーションの本番運用に不可欠
- 自動スケーリングと高可用性の実現
- マイクロサービスアーキテクチャの実装基盤
- クラウドネイティブアプリケーション開発の中心技術

**教材**: https://www.udemy.com/course/aws-eks-kubernetes-docker-devops-best-practices-2020/

こちらにまとめてます
https://github.com/haruka-aibara/tech-learnings/tree/main/Infrastructure/Containers/Orchestration/Kubernetes/Roadmap-Based-Learning

## 18. アプリケーションモニタリング
### Datadog、Prometheus
**概要**: アプリケーションのパフォーマンス監視、トレーシング、ユーザーエクスペリエンス分析ツール。

**この段階で学ぶ理由**:
- アプリケーション層の問題特定に必須
- エンドユーザー体験の理解と最適化
- マイクロサービス間の依存関係と通信の可視化
- ビジネスメトリクスとの関連付け

こちらにまとめてます
未作成　roadmap.sh なし

## 20. GitOps
### ArgoCD
**概要**: Kubernetesのための宣言型GitOps継続的デリバリーツール。Gitリポジトリをソースオブトゥルースとして使用。

**この段階で学ぶ理由**:
- 宣言型の継続的デリバリー実現
- Kubernetes環境の一貫性確保
- 変更の追跡と監査が容易
- 自動修復と同期機能による運用負荷軽減

こちらにまとめてます
未作成　roadmap.sh なし

## 21. サービスメッシュ
### Envoy
**概要**: マイクロサービス間の通信を制御・監視するプロキシ。トラフィック管理、セキュリティ、可観測性を提供。

**この段階で学ぶ理由**:
- マイクロサービスアーキテクチャの複雑さに対処
- サービス間通信の統一的な管理
- 高度なトラフィック制御と安全性の確保
- サービスメッシュの基盤技術として広く採用

こちらにまとめてます
未作成　roadmap.sh なし

## 22. クラウドデザインパターン
### 可用性、データ管理、設計と実装、管理とモニタリング
**概要**: クラウドネイティブアプリケーション設計のための標準的なアーキテクチャパターン集。

**この段階で学ぶ理由**:
- スケーラブルで回復力のある設計の基礎
- 共通の問題に対する検証済みの解決策
- ベストプラクティスの体系的理解
- クラウドの利点を最大限に活用するための知識

こちらにまとめてます
未作成　roadmap.sh なし
