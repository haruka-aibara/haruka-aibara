<!-- Space: harukaaibarapublic -->
<!-- Parent: AWSセキュリティ成熟度モデル -->
<!-- Title: AWSセキュリティ成熟度モデル v2 Terraform 実装例 -->

# AWSセキュリティ成熟度モデル v2 — Terraform リソース早見表

各項目を実装するときに使う主なTerraformリソース名をまとめたもの。
コードは自分で書く前提で、「このへんを調べれば実装できる」レベルの情報。

各項目に以下を記載している：
- **最善**: 理想的なアプローチ（コストや依存関係を問わない場合の推奨）
- **妥協点**: メンバーアカウント単独や工数制約がある場合の現実的な選択肢
- **デメリット**: 妥協点を選んだときに残るリスクや注意点

> `*` は Org 管理アカウント（または委任管理者）が必要なリソース

---

## 1. セキュリティガバナンス

#### セキュリティ連絡先の割当て
> **最善**: Control Tower の Account Factory でアカウント作成時に連絡先を自動設定  
> **妥協点**: `aws_account_alternate_contact` をアカウントごとに Terraform で適用  
> **デメリット**: アカウントが増えるたびに適用漏れリスク。アカウント内管理者が変更できるため、変更検知（Config ルール等）を別途用意しないと気づけない

- `aws_account_alternate_contact`

#### リージョンの選択と無効化
> **最善**: SCP (`aws_organizations_policy`) で `aws:RequestedRegion` 条件による Deny。コアリージョンを含む全リージョンに適用可能  
> **妥協点**: `aws_account_region` でオプトインリージョンを無効化（メンバーアカウント単独で可）  
> **デメリット**: `aws_account_region` は `us-east-1` 等のコアリージョンを無効化できない。`account:EnableRegion` 権限を持つ管理者が再有効化できる。IAM / Route 53 等グローバルサービスはリージョン制限の対象外

- `aws_account_region`（オプトインリージョンの無効化・メンバーアカウントで可）
- `aws_organizations_policy` + `aws_organizations_policy_attachment` ＊（SCP によるリージョン制限）

#### コンプライアンスと規制要件の特定
> **最善**: Audit Manager でフレームワークを定義し、自動エビデンス収集まで構築  
> **妥協点**: S3 に文書を保管する程度  
> **デメリット**: ほぼ人的プロセスが中心。Terraform で強制できる要素はほぼない

- Terraform で管理するものは特になし（文書管理）
- 強いて言えば文書置き場の `aws_s3_bucket`

#### セキュリティ研修計画
> **最善**: AWS Skill Builder 等の外部プラットフォームと連携し、受講状況を定期レポート化  
> **妥協点**: S3 に資料を配置して IAM でアクセス制御  
> **デメリット**: 受講の強制・進捗追跡は Terraform 外。技術的な担保手段がない

- Terraform で管理するものは特になし（プロセス）

#### セキュアなアーキテクチャ設計
> **最善**: Well-Architected Tool + 設計レビューを CI に組み込み、問題があるとデプロイを止める  
> **妥協点**: `aws_wellarchitected_workload` でレビュー記録を管理するだけ  
> **デメリット**: ツールは記録するだけで設計品質を保証しない。レビュー実施・改善は人依存

- `aws_wellarchitected_workload`（Well-Architected Review の記録）
- 構成図・設計文書の置き場として `aws_s3_bucket`

#### Infrastructure as Code の活用
> **最善**: CodePipeline + OPA/Checkov で自動ポリシーチェック + PR 必須ワークフロー + drift 検出  
> **妥協点**: S3 state + DynamoDB lock だけ設定  
> **デメリット**: ポリシーチェックなしだと IaC 自体が攻撃経路になる。drift 検出がないと手動変更を見逃す。state ファイルに機密情報が入ることがある

- Terraform state 管理: `aws_s3_bucket` + `aws_dynamodb_table`
- デプロイ前チェック: `aws_codecommit_repository` + `aws_codepipeline`（CloudFormation Guard は Terraform 外）

#### タグ付け戦略
> **最善**: Organizations の TAG_POLICY でタグなしリソース作成を拒否 + Config ルールで継続監視  
> **妥協点**: Config ルール (`required-tags`) で事後検出・通知のみ  
> **デメリット**: Config は作成を防げず検出後の修正が必要。TAG_POLICY は正規表現でタグ値の書式を強制できるが、値の意味的な正しさまでは担保できない

- `aws_resourcegroups_group`（タグベースのリソースグループ）
- タグポリシー強制: `aws_organizations_policy`（type = `TAG_POLICY`）＊
- Config でタグ検証: `aws_config_config_rule`（managed rule: `required-tags`）

#### セキュリティタスクの責任分担
> **最善**: RACI を文書化し、IAM ロール・ポリシーで技術的にも役割を分離  
> **妥協点**: IAM ポリシーで操作できるリソースを役割ごとに制限するだけ  
> **デメリット**: RACI 自体は Terraform で強制不可。組織変更に合わせた継続的な更新が人力になる

- Terraform で管理するものは特になし（RACI はドキュメント）

---

## 2. セキュリティ保証

#### クラウドセキュリティポスチャ管理 (CSPM)
> **最善**: Organizations 委任管理者 + Finding Aggregator で全アカウント・全リージョンを一元集約 + 通知自動化  
> **妥協点**: `aws_securityhub_account` をメンバーアカウントで有効化のみ  
> **デメリット**: 集約なしだとアカウントをまたいだ全体像が掴めない。通知設定がないと検出だけで対応が遅れる

- `aws_securityhub_account`
- `aws_securityhub_standards_subscription`（CIS / AWS基礎ベストプラクティス）
- `aws_securityhub_finding_aggregator`（リージョン横断集約）
- `aws_securityhub_organization_configuration` ＊（組織全体への自動有効化）

#### インベントリと設定モニタリング
> **最善**: Organizations 全アカウント展開 + Conformance Pack で標準ルールセットを一括配布  
> **妥協点**: `aws_config_configuration_recorder` + 基本ルール数本をアカウント単体で設定  
> **デメリット**: アカウントごとに設定が必要で漏れが出やすい。全リソースタイプを記録するとコストが高い。記録だけで自動修復がないと対応が手動になる

- `aws_config_configuration_recorder`
- `aws_config_delivery_channel`
- `aws_config_config_rule`
- `aws_config_organization_managed_rule` ＊（組織全体展開）
- `aws_config_remediation_configuration`（SSM Automation 自動修復）

#### コンプライアンスレポートの作成
> **最善**: Audit Manager + 自動エビデンス収集 + レポート生成の自動化  
> **妥協点**: `aws_auditmanager_assessment` で枠だけ作り、レポートは手動出力  
> **デメリット**: エビデンス収集の設定が複雑。監査範囲外のコントロールは手動対応が必要で、結局工数がかかる

- `aws_auditmanager_assessment`
- `aws_auditmanager_framework`
- `aws_auditmanager_control`

#### 監査証拠の収集自動化
> **最善**: CloudTrail + Security Hub + Audit Manager を連携して自動エビデンス収集  
> **妥協点**: CloudTrail を有効化してログを S3 に残すだけ（証拠のソースとして利用）  
> **デメリット**: CloudTrail のみでは証拠の整理・提出は手動。Audit Manager の設定・維持コストが高く、初期構築に工数がかかる

- `aws_auditmanager_assessment`（CloudTrail / Security Hub からの自動エビデンス収集）
- `aws_cloudtrail`（エビデンスのソース）

---

## 3. ID とアクセス管理

#### 多要素認証 (MFA) の設定
> **最善**: IAM Identity Center で MFA 必須化 + フィッシング耐性のある FIDO2 デバイスを要求  
> **妥協点**: IAM ポリシーに `aws:MultiFactorAuthPresent: false` の Deny 条件を追加  
> **デメリット**: IAM ポリシーによる MFA 強制はルートユーザーやアクセスキーには適用されない。新規 IAM ユーザー作成を制限しないと MFA 未設定ユーザーが作られる抜け道になる

- MFA 強制ポリシー: `aws_iam_policy`（`aws:MultiFactorAuthPresent` 条件付き Deny）
- `aws_iam_account_password_policy`（パスワードポリシー）
- Cognito MFA: `aws_cognito_user_pool`（`mfa_configuration = "ON"`）

#### ルートの保護
> **最善**: SCP でルート操作を全面 Deny + ルートメールアドレスをセキュリティチームの配布リストに設定  
> **妥協点**: CloudWatch + SNS でルートログインを検出・通知のみ  
> **デメリット**: 通知は事後検出のみ。SCP がなければルート操作は防げない。ログインに気づいたときには操作済みの場合がある

- `aws_cloudwatch_log_metric_filter`（root ログイン検知）
- `aws_cloudwatch_metric_alarm`（root ログイン通知）
- `aws_sns_topic` + `aws_sns_topic_subscription`
- SCP で root 操作拒否: `aws_organizations_policy` ＊

#### ID フェデレーション
> **最善**: IAM Identity Center + 外部 IdP (Okta/Azure AD) + MFA 必須 + セッション時間の制限  
> **妥協点**: アカウントレベル SAML (`aws_iam_saml_provider`) で個別設定  
> **デメリット**: アカウントレベル SAML は管理が分散する。セッション時間・属性マッピングのカスタマイズが Identity Center より制限される。アカウントごとに設定が必要で漏れが出やすい

- `aws_iam_saml_provider`（アカウントレベル SAML）
- IAM Identity Center（SSO）は Terraform Provider `aws` の `aws_ssoadmin_*` リソース群 ＊
  - `aws_ssoadmin_instance_access_control_attributes`
  - `aws_ssoadmin_permission_set`
  - `aws_ssoadmin_account_assignment`

#### 意図しないアクセス権限の削除
> **最善**: Access Analyzer (ORGANIZATION タイプ) + Unused Access 検出 + 定期レビューの自動化  
> **妥協点**: ACCOUNT タイプの Access Analyzer で外部アクセスの検出のみ  
> **デメリット**: ACCOUNT タイプは「外部公開」の検出が主目的で過剰権限の検出には別途 ACCOUNT_UNUSED_ACCESS が必要。Unused Access の検出精度は限定的で、実際に使っているかどうかは人が確認する必要がある

- `aws_accessanalyzer_analyzer`（type = `ACCOUNT` or `ORGANIZATION`）
- 未使用アクセスの検出: `aws_accessanalyzer_analyzer`（type = `ACCOUNT_UNUSED_ACCESS`）

#### 組織のアクセス許可ガードレール
> **最善**: SCP（プリンシパル側の制限）+ RCP（リソース側の制限）の両方を組み合わせる  
> **妥協点**: SCP のみでプリンシパル側を制限  
> **デメリット**: SCP だけではリソースポリシーは制御できない（例: S3 バケットポリシーで外部許可を防ぐには RCP が必要）。どちらも組織管理アカウントが必要で、メンバーアカウント単独では使えない

- `aws_organizations_policy`（type = `SERVICE_CONTROL_POLICY`）＊
- `aws_organizations_policy`（type = `RESOURCE_CONTROL_POLICY`）＊
- `aws_organizations_policy_attachment` ＊

#### 一時的な認証情報の使用
> **最善**: 全サービスを IAM ロールに移行し、長期アクセスキーを撲滅。SCP でアクセスキー作成を Deny  
> **妥協点**: `aws_secretsmanager_secret_rotation` でアクセスキーをローテーション  
> **デメリット**: ローテーションしても長期認証情報はリスクが残る。漏洩から無効化までの窓口が存在する。ローテーション直後のキーが漏洩すると最大ローテーション期間分の被害が出る

- `aws_iam_role` + `aws_iam_instance_profile`（EC2）
- `aws_iam_role`（Lambda / ECS Task Role）
- `aws_secretsmanager_secret` + `aws_secretsmanager_secret_rotation`
- シークレットスキャン CI: `aws_codebuild_project`

#### IMDSv2
> **最善**: `aws_ec2_instance_metadata_defaults` でアカウントレベルのデフォルトを v2 必須に設定 + SCP で v1 を許可するインスタンス作成を Deny  
> **妥協点**: `aws_instance` ごとに `http_tokens = "required"` を設定  
> **デメリット**: インスタンスごとの設定は漏れが生じやすい。既存インスタンスは再作成または手動変更が必要。ECS / EKS の IMDS 設定は別途必要。一部の旧アプリは IMDSv2 に非対応の場合がある

- `aws_ec2_instance_metadata_defaults`（アカウントレベルのデフォルト設定）
- `aws_instance`（`metadata_options.http_tokens = "required"`）
- Config ルール検証: `aws_config_config_rule`（managed rule: `ec2-imdsv2-check`）

#### 最小権限の見直し
> **最善**: Access Analyzer ポリシー生成 + CI/CD パイプラインでの自動チェック + ワイルドカード禁止ゲート  
> **妥協点**: Access Analyzer を有効化して定期的に手動レビューのきっかけ作りとして使う  
> **デメリット**: 自動化なしだと継続的な見直しは困難。Access Analyzer のポリシー生成には 90 日分の CloudTrail データが必要。最小権限への絞り込みはアプリの動作テストとセットでないと安易に絞れない

- `aws_accessanalyzer_analyzer`（CloudTrail ベースのポリシー生成のソース）
- `aws_iam_policy` + `aws_iam_role_policy_attachment`（最小権限ポリシーの管理）
- `aws_codepipeline`（IAM ポリシーの変更フロー自動化）

#### 顧客 ID とアクセス管理(CIAM)
> **最善**: Cognito + WAF (ATP ルール) + MFA 必須 + メール検証 + パスワードポリシー強化  
> **妥協点**: `aws_cognito_user_pool` 基本設定のみ（MFA は任意）  
> **デメリット**: 高度なカスタマイズには Lambda トリガーが必要で複雑化する。ATP ルールは追加コストあり。Cognito の UI カスタマイズは制限が多い

- `aws_cognito_user_pool`
- `aws_cognito_user_pool_client`
- `aws_wafv2_web_acl`（ATP: AccountTakeoverProtection ルール）

#### IAM データ境界の活用
> **最善**: Permission Boundary + SCP + RCP の三層で Confused Deputy 攻撃を多面的に防止  
> **妥協点**: Permission Boundary のみでロール権限の上限を設定  
> **デメリット**: Permission Boundary は全ロールに明示的に設定が必要で漏れが出やすい。SCP がなければ管理者が Boundary を削除できる。三層を組み合わせると設計が複雑になりデバッグが困難

- RCP: `aws_organizations_policy`（type = `RESOURCE_CONTROL_POLICY`）＊
- S3 バケットポリシー条件: `aws_s3_bucket_policy`（`aws:SourceVpc` / `aws:PrincipalOrgID` 条件）
- `aws_iam_policy`（Permission Boundary）

#### IAM ポリシー生成パイプライン
> **最善**: IaC パイプライン + `aws iam policy simulate` でのテスト + PR マージゲート + ワイルドカード自動検出  
> **妥協点**: CodePipeline に Access Analyzer のポリシー検証ステップを追加するだけ  
> **デメリット**: パイプライン自体が過剰権限だと攻撃経路になる。初期構築コストが高い。ポリシーの「正しさ」をテストケースで担保しないと誤った最小化が起きる

- `aws_codepipeline` + `aws_codebuild_project`（IAM-as-Code パイプライン）
- `aws_lambda_function`（ワイルドカード自動検出・拒否）
- `aws_iam_policy`（IaC 管理）

#### 一時的な昇格アクセスの管理
> **最善**: TEAM ソリューション + 承認フロー + 全操作の監査証跡記録  
> **妥協点**: `aws_iam_role` で最大セッション時間を短く設定した昇格用ロールを常設  
> **デメリット**: 常設ロールはソーシャルエンジニアリングや内部不正で悪用されるリスク。承認フロー省略が起きやすい。セッション時間を短くしても、その時間内に操作は完了できる

- `aws_iam_role`（昇格用ロール、最大セッション時間を短く設定）
- `aws_ssoadmin_permission_set`（TEAM ソリューション用）
- 承認フロー: `aws_sfn_state_machine` + `aws_lambda_function`
- 監査: `aws_cloudtrail`

---

## 4. 脅威検出

#### 基本の脅威検出
> **最善**: GuardDuty + Organizations 全アカウント自動有効化 + EventBridge → Security Hub 集約 + 通知自動化  
> **妥協点**: `aws_guardduty_detector` をアカウント単体で有効化のみ  
> **デメリット**: アカウントごとの有効化では見落としリスク。Findings の通知設定がないと検出だけで対応されない。GuardDuty 単体では自動対応できず、Lambda 連携が別途必要

- `aws_guardduty_detector`
- `aws_guardduty_organization_configuration` ＊（組織全体への自動有効化）
- `aws_sns_topic` + `aws_cloudwatch_event_rule`（Findings 通知）

#### API 呼び出し監査
> **最善**: 組織証跡 (`is_organization_trail = true`) + S3 Object Lock + CloudTrail Lake でクエリ高速化  
> **妥協点**: アカウント単体の CloudTrail を S3 に記録  
> **デメリット**: アカウント内管理者がログを削除できる（S3 Object Lock + 別アカウントへの保存が必要）。S3 保存のみだと Athena 経由のクエリが遅い。CloudTrail Lake は追加コストあり

- `aws_cloudtrail`（`is_organization_trail = true` で組織証跡）
- `aws_s3_bucket` + `aws_s3_bucket_policy`（ログ保存先）
- `aws_cloudtrail_event_data_store`（CloudTrail Lake）
- Config ルール: `aws_config_config_rule`（`cloud-trail-enabled`）

#### 請求アラーム
> **最善**: Cost Anomaly Detection + Budgets + 閾値の定期的な見直し自動化  
> **妥協点**: Budgets で固定閾値アラームのみ設定  
> **デメリット**: 固定閾値は事業成長に合わせて手動更新が必要。Cost Anomaly の検出には最大 24 時間の遅延があり、その間に被害が拡大する可能性がある

- `aws_cloudwatch_metric_alarm`（`aws_billing` namespace）
- `aws_budgets_budget`
- `aws_ce_anomaly_monitor` + `aws_ce_anomaly_subscription`

#### 高度な脅威検出
> **最善**: 全 GuardDuty 機能 (Runtime Monitoring / Malware Protection / S3 / RDS / EKS / Lambda) を有効化  
> **妥協点**: 基本 GuardDuty のみ + Runtime Monitoring を重要 EC2/ECS に絞って有効化  
> **デメリット**: Runtime Monitoring はエージェントのインストールが必要で既存環境への展開にコストがかかる。有効化機能が増えるとコストが増加する。全機能を有効化しても Findings への対応プロセスがないと意味がない

- `aws_guardduty_detector_feature`（Runtime Monitoring / Malware Protection / S3 / RDS / EKS）
- `aws_guardduty_malware_protection_plan`

#### カスタム脅威検出 (SIEM/SecLake)
> **最善**: Security Lake + OCSF 標準フォーマットで複数ソースを集約 + SIEM と統合  
> **妥協点**: CloudWatch Logs + Kinesis Firehose で S3 に集約 + Athena でクエリ  
> **デメリット**: Security Lake は対応リージョン・ソースが限定的。自前 SIEM は運用コストが高い。ログ量が多いと S3 + Athena のコストが想定外に増加する

- `aws_securitylake_data_lake` ＊（Security Lake 組織設定）
- `aws_securitylake_subscriber`
- ログ集約: `aws_cloudwatch_log_group` + `aws_kinesis_firehose_delivery_stream`
- SIEM 自前構築: `aws_opensearch_domain`

#### 脅威インテリジェンスの活用
> **最善**: GuardDuty カスタム脅威 IP + WAF マネージドルール + IP リストの定期的な自動更新  
> **妥協点**: AWS マネージドの IP レピュテーションルールのみ利用  
> **デメリット**: カスタム IP リストの更新を怠ると古い情報になる。GuardDuty の誤検知が増えるとアラート疲れが起きて重要な検出を見逃す。IP ベースの制御は VPN やプロキシで容易に迂回される

- `aws_guardduty_threat_intel_set`（カスタム脅威 IP リスト）
- WAF IPセット: `aws_wafv2_ip_set`（IP レピュテーションリスト）
- `aws_wafv2_web_acl`（マネージド IP レピュテーションルール: `AWSManagedRulesAmazonIpReputationList`）

#### VPC フローログの分析
> **最善**: 全 VPC のフローログ + Security Lake への集約 + GuardDuty ネットワーク検出と組み合わせ  
> **妥協点**: フローログを S3 に保存のみ（Athena クエリは必要時のみ）  
> **デメリット**: フローログはトラフィック量が多いと S3 コストが急増する。リアルタイム検出には Kinesis + Lambda が必要で構成が複雑化する。フローログは「何が通ったか」はわかるが「何を運んだか」（ペイロード）はわからない

- `aws_flow_log`（VPC / Subnet / ENI 単位で設定）
- 保存先: `aws_cloudwatch_log_group` または `aws_s3_bucket`
- 分析: `aws_athena_workgroup` + `aws_glue_catalog_database`（S3 保存時）

---

## 5. 脆弱性管理

#### インフラの脆弱性管理
> **最善**: Inspector2 + SSM Patch Manager で自動パッチ適用（テスト環境→本番の順で展開）  
> **妥協点**: Inspector2 有効化のみ（パッチ適用は手動）  
> **デメリット**: Inspector2 は検出のみで修復は SSM Patch Manager の別途設定が必要。自動パッチ適用はサービス停止リスクがあるため Maintenance Window と組み合わせた慎重な設定が必要

- `aws_inspector2_enabler`
- `aws_inspector2_organization_configuration` ＊
- `aws_ssm_patch_baseline` + `aws_ssm_patch_group`
- `aws_ssm_maintenance_window` + `aws_ssm_maintenance_window_task`

#### アプリケーションの脆弱性管理
> **最善**: ECR 自動スキャン + CodePipeline にスキャンゲートを設定し Critical 検出時はデプロイ自動ブロック  
> **妥協点**: ECR スキャンを有効化して結果を確認するだけ（ゲートなし）  
> **デメリット**: スキャンゲートなしだと脆弱なイメージがデプロイされる。DAST はランタイム環境が必要で CI のみでは不十分。脆弱性の修正責任を明確にしないとスキャン結果が放置される

- `aws_ecr_registry_scanning_configuration`（ECR イメージスキャン）
- `aws_codebuild_project`（SAST/SCA をパイプラインに組み込む）
- `aws_codepipeline`（Critical 脆弱性でのデプロイブロック）

#### セキュリティチャンピオンの配置
> **最善**: 各開発チームにセキュリティ担当を置く組織設計 + 定期的なトレーニングと情報共有  
> **妥協点**: Slack チャンネルやメーリングリストでセキュリティ情報を共有する程度  
> **デメリット**: 技術的な強制手段は存在しない。担当者の異動・退職で形骸化しやすい

- Terraform で管理するものは特になし（人・プロセス）

#### DevSecOps とパイプライン
> **最善**: Image Builder + SAST/DAST/SCA を全 CI/CD パイプラインに組み込み、失敗時はデプロイを停止するゲートを設定  
> **妥協点**: SAST ツールをパイプラインに追加するだけで結果は通知のみ（ゲートなし）  
> **デメリット**: ゲートなしだと検出が形骸化する。DAST は実行環境が必要でパイプライン構成が複雑化する。セキュリティチェックが遅くてデプロイが遅延するとチームに嫌われてスキップされる

- `aws_imagebuilder_image_pipeline`（ゴールデンイメージ）
- `aws_imagebuilder_image_recipe`
- `aws_codebuild_project`（SAST/DAST）
- `aws_codepipeline`

#### 脆弱性管理チームの組成
> **最善**: 専任チーム + KPI 管理 + SLA による修復期限の強制  
> **妥協点**: CloudWatch Dashboard で脆弱性状況を可視化してチームが確認できるようにする  
> **デメリット**: ダッシュボードがあっても対応する人・プロセスがなければ意味がない。技術的な強制手段は存在しない

- Terraform で管理するものは特になし（組織・プロセス）
- ダッシュボード用に `aws_cloudwatch_dashboard`

---

## 6. インフラストラクチャー保護

#### 危険な通信ポートのブロック
> **最善**: Config 自動修復 + IaC でのみ SG 変更可能にする（コンソール変更を SCP で制限）  
> **妥協点**: Config ルール (`restricted-ssh`) で検出して通知のみ  
> **デメリット**: 検出から修復まで時間差がある。SCP がなければアカウント内管理者がコンソールから SG を変更できる。自動修復は設定ミスで正常なルールを削除するリスクがある

- `aws_security_group`（`ingress` ルールから 22/3389 を排除）
- Config 自動修復: `aws_config_config_rule`（`restricted-ssh` / `restricted-common-ports`）+ `aws_config_remediation_configuration`

#### ネットワークアクセスの制限
> **最善**: Firewall Manager (FMS) で組織横断の SG ポリシーを強制  
> **妥協点**: `aws_security_group` をアカウントごとに IaC 管理  
> **デメリット**: FMS なしだとアカウントが増えるたびに手動設定が必要。SG ルールのドリフト検出の仕組みが別途必要。NACL は SG を補完するが設定ミスでサービスが停止しやすい

- `aws_security_group`（SGチェーン: ALB SG → Web SG → DB SG）
- `aws_network_acl`
- `aws_fms_policy` ＊（Firewall Manager による組織横断の SG ポリシー）

#### EC2 インスタンスの安全な管理
> **最善**: Session Manager 経由のアクセスのみ許可 + SCP で SSH キーペア作成を Deny + セッションログを S3/CloudWatch に記録  
> **妥協点**: SSM Agent インストール + Instance Profile 設定で Session Manager を使えるようにするだけ  
> **デメリット**: SCP がなければ SSH も引き続き使われる可能性がある。Session Manager のセッションログを記録しないと操作の監査証跡がない

- `aws_ssm_association`（SSM Agent の設定確認・自動修復）
- `aws_iam_instance_profile`（SSM 用の IAM ロール）
- `aws_ssm_document`（Session Manager のセッション設定）
- `aws_ssm_session_manager_preferences`

#### ネットワークのセグメント化
> **最善**: Transit Gateway + 中央 Inspection VPC (Network Firewall) でアカウント間の East-West トラフィックを集中検査  
> **妥協点**: VPC + Subnet 分割 + NAT Gateway + Route Table で基本セグメント化  
> **デメリット**: VPC ピアリングは推移的ルーティングなし（スター型になり管理が煩雑）。Inspection VPC なしだとアカウント間通信が検査されない。サブネット分割だけでは同一サブネット内の通信は制御できない

- `aws_vpc`
- `aws_subnet`（public / private / isolated）
- `aws_nat_gateway`
- `aws_route_table` + `aws_route_table_association`
- `aws_vpc_peering_connection`（ピアリング、業務要件をコメントで文書化）

#### マルチアカウント管理
> **最善**: Control Tower + Account Factory for Terraform (AFT) でアカウント発行を完全自動化・標準化  
> **妥協点**: Organizations だけで OU 構造を作り、新規アカウントは手動作成  
> **デメリット**: Control Tower なしだとアカウントへのガードレール適用・ベースライン設定が属人化しやすい。手動アカウント作成は設定漏れが起きやすい

- `aws_organizations_organizational_unit` ＊
- `aws_organizations_account` ＊
- `aws_controltower_landing_zone` ＊（Control Tower）

#### ゴールデンイメージパイプライン
> **最善**: Image Builder パイプライン + Inspector2 脆弱性スキャン + AMI 自動更新 + 古い AMI の自動削除  
> **妥協点**: Image Builder でイメージ作成だけ自動化（スキャンなし）  
> **デメリット**: スキャンなしのゴールデンイメージは脆弱なまま使い続けるリスクがある。AMI の更新を実行中インスタンスの更新まで連携しないと新旧が混在する

- `aws_imagebuilder_image_pipeline`
- `aws_imagebuilder_image_recipe`
- `aws_imagebuilder_component`（OS ハードニング手順）
- `aws_imagebuilder_distribution_configuration`
- Config 検証: `aws_config_config_rule`（`approved-amis-by-tag`）

#### マルウェア対策
> **最善**: GuardDuty Malware Protection + サードパーティ EDR (CrowdStrike 等) を SSM Distributor で展開  
> **妥協点**: GuardDuty Malware Protection のみ  
> **デメリット**: GuardDuty Malware Protection のスキャンタイミングは限定的（ファイル作成時等）。リアルタイム保護とプロセス監視には EDR が必要。EDR のエージェント管理・更新の運用コストがかかる

- `aws_guardduty_detector_feature`（Malware Protection for EC2）
- サードパーティ EDR の展開: `aws_ssm_association`（SSM Distributor でエージェント配布）

#### アウトバウンド通信の制御
> **最善**: Network Firewall + DNS Firewall の組み合わせで多層制御（ドメイン + IP + プロトコル）  
> **妥協点**: DNS Firewall でドメインベースのフィルタリングのみ  
> **デメリット**: DNS Firewall は DNS クエリのみ制御する。直接 IP 通信や DNS over HTTPS を使う場合は迂回される。Network Firewall は高額でスループットに比例してコストが増加する

- `aws_route53_resolver_firewall_rule_group`（DNS Firewall）
- `aws_route53_resolver_firewall_domain_list`
- `aws_route53_resolver_firewall_rule_group_association`
- `aws_networkfirewall_firewall`（多層検査が必要な場合）
- `aws_networkfirewall_firewall_policy` + `aws_networkfirewall_rule_group`
- `aws_vpc_endpoint`（PrivateLink）

#### ゼロトラストアクセスの実装
> **最善**: Verified Access + IdP 連携 + デバイス証明書 + セッション別アクセス制御  
> **妥協点**: Verified Access で IdP 連携のみ（デバイス検証なし）  
> **デメリット**: デバイス検証なしでは BYOD リスクが残る。VPN 置き換えには既存アプリケーションの設定変更が必要。Verified Access はまだ機能・リージョン対応が発展途上

- `aws_verifiedaccess_instance`
- `aws_verifiedaccess_trust_provider`（IdP / デバイスコンテキスト）
- `aws_verifiedaccess_group`
- `aws_verifiedaccess_endpoint`

#### 抽象化サービスの利用
> **最善**: サーバーレス (Lambda) または Fargate を優先採用し、OS 管理を AWS に委任  
> **妥協点**: 既存 EC2 を Lambda/ECS に順次移行  
> **デメリット**: Lambda は実行時間・メモリ・同時実行数の制限がある。コンテナへの移行は既存アプリの改修コストが高い。サーバーレスでも関数コードの脆弱性・依存ライブラリの管理は引き続き必要

- `aws_lambda_function`（サーバーレス移行先）
- `aws_ecs_task_definition`（コンテナ化）
- `aws_api_gateway_rest_api` / `aws_apigatewayv2_api`
- 移行効果測定: `aws_cloudwatch_dashboard`

---

## 7. データ保護

#### パブリックアクセスのブロック
> **最善**: アカウントレベル BPA + SCP で BPA 解除を Deny + Config ルールで継続監視  
> **妥協点**: `aws_s3_account_public_access_block` のみ設定  
> **デメリット**: アカウントレベル BPA はアカウント内管理者が解除できる（SCP がなければ）。バケットレベルの BPA 設定とは独立しているため、両方の確認が必要

- `aws_s3_account_public_access_block`（アカウントレベル BPA）
- `aws_ec2_image_block_public_access`（AMI BPA）
- `aws_ebs_encryption_by_default`（EBS デフォルト暗号化と合わせて）
- SCP でBPA解除防止: `aws_organizations_policy` ＊

#### データセキュリティポスチャの分析
> **最善**: Macie 自動データ機密性検出（継続的スキャン）+ Organizations 全アカウント展開  
> **妥協点**: 特定バケットに対して手動ジョブを定期実行  
> **デメリット**: Macie はデータ量に比例してコストが高い。日本固有のデータ形式（マイナンバー等）は組み込み識別子だけでは検出精度が低い。全バケット自動スキャンはコストが予測しにくい

- `aws_macie2_account`
- `aws_macie2_classification_job`（自動データ機密性検出）
- `aws_macie2_organization_configuration` ＊

#### 保存時のデータ暗号化
> **最善**: CMK (Customer Managed Key) + キーポリシーで管理者を分離 + `enable_key_rotation = true`  
> **妥協点**: AWS マネージドキー (SSE-S3 / SSE-KMS 自動) でデフォルト暗号化のみ  
> **デメリット**: AWS マネージドキーはキーポリシーのカスタマイズ不可。CMK は管理コスト（ローテーション・削除保護・アクセス制御）が増加し、KMS API コストも発生する。キー削除すると復号できなくなるため削除保護の設定が必須

- `aws_kms_key` + `aws_kms_alias`
- `aws_kms_key`（`enable_key_rotation = true`）
- `aws_s3_bucket_server_side_encryption_configuration`
- `aws_rds_cluster` / `aws_db_instance`（`storage_encrypted = true`）
- `aws_ebs_encryption_by_default`

#### データのバックアップ
> **最善**: AWS Backup + クロスアカウント・クロスリージョン保存 + Vault Lock (WORM) で改ざん防止  
> **妥協点**: Backup Vault + Plan でスナップショットを定期取得のみ  
> **デメリット**: Vault Lock なしだとランサムウェア攻撃でバックアップごと削除される可能性がある。クロスアカウント保存なしだと同一アカウントが侵害されるとバックアップも無効化される

- `aws_backup_vault`
- `aws_backup_plan`
- `aws_backup_selection`
- `aws_backup_vault_policy`（クロスアカウント保護）
- `aws_backup_region_settings`

#### 機密データの検出
> **最善**: Macie 自動検出 + カスタム識別子で業界・国固有の機密データパターンを追加  
> **妥協点**: Macie の組み込み識別子のみで特定バケットをスキャン  
> **デメリット**: 組み込み識別子は日本固有データ形式に弱い場合がある。全バケットスキャンは高コスト。検出しても対応プロセスがないと放置される

- `aws_macie2_account`
- `aws_macie2_custom_data_identifier`（カスタム識別子）
- `aws_macie2_classification_job`

#### 通信の暗号化
> **最善**: ACM + Private CA（内部通信用）+ TLS 1.2 以上強制 + 証明書の自動更新  
> **妥協点**: ACM パブリック証明書で外部通信のみ暗号化  
> **デメリット**: 内部通信（VPC 内）が暗号化されていないと East-West 攻撃で盗聴可能。証明書の有効期限管理が漏れると突然サービスが停止する。Private CA はコストが高い（月額 $400〜）

- `aws_acm_certificate`（パブリック証明書）
- `aws_acmpca_certificate_authority`（Private CA / 内部通信用）
- `aws_lb_listener`（`protocol = "HTTPS"`）
- `aws_api_gateway_domain_name`

#### 生成 AI データの保護
> **最善**: Bedrock Guardrail + VPC エンドポイント + プロンプトのログ記録 + 機密データマスキング  
> **妥協点**: Bedrock Guardrail の基本設定のみ（コンテンツフィルタリング）  
> **デメリット**: Guardrail はプロンプトインジェクション対策が限定的。VPC エンドポイントなしだとプロンプトがパブリックネットワークを経由する。モデルの応答が機密情報を含む場合のログ管理に注意が必要

- `aws_bedrock_guardrail`
- `aws_bedrock_guardrail_version`
- `aws_vpc_endpoint`（Bedrock 用 VPC エンドポイント）

---

## 8. アプリケーションセキュリティ

#### WAF とマネージドルールの活用
> **最善**: FMS で組織全体に WAF ポリシーを強制 + マネージドルールのカスタムチューニング  
> **妥協点**: アカウントごとに `aws_wafv2_web_acl` を設定してマネージドルールを適用  
> **デメリット**: FMS なしだと各アカウントで別々に設定が必要。マネージドルールはデフォルト設定だと誤検知が起きる場合があり、チューニングに継続的な工数が必要

- `aws_wafv2_web_acl`（マネージドルール: `AWSManagedRulesCommonRuleSet` 等）
- `aws_wafv2_web_acl_association`（ALB / API Gateway への関連付け）
- Firewall Manager 一括適用: `aws_fms_policy` ＊

#### セキュリティチームの関与
> **最善**: SDLC の各フェーズ（要件定義・設計・実装・テスト）にセキュリティレビューを組み込む  
> **妥協点**: `aws_wellarchitected_workload` でレビュー記録を残す  
> **デメリット**: 人的プロセスが中心で技術的な強制手段がない。レビューが形式化すると実質的な効果がなくなる

- Terraform で管理するものは特になし（プロセス）
- 設計レビュー記録: `aws_wellarchitected_workload`

#### コード内のシークレット管理
> **最善**: Secrets Manager + 自動ローテーション + CI でのシークレットスキャン (git-secrets/Gitleaks) をマージゲートに設定  
> **妥協点**: Secrets Manager に移行するだけ（ローテーション・CI スキャンなし）  
> **デメリット**: ローテーションなしのシークレットは漏洩しても気づきにくい。CI スキャンがないとシークレットが誤ってコミットされたままになる。Secrets Manager への移行時に古い設定ファイルにシークレットが残るリスク

- `aws_secretsmanager_secret`
- `aws_secretsmanager_secret_version`
- `aws_secretsmanager_secret_rotation`
- `aws_ssm_parameter`（Parameter Store SecureString）
- git-secrets / Gitleaks は CI 側の設定（Terraform 外）

#### 脅威モデリングの実施
> **最善**: STRIDE/LINDDUN などの体系的な手法 + 設計変更のたびにアップデート  
> **妥協点**: 設計ドキュメントを S3 に保管して履歴管理  
> **デメリット**: 技術的な強制手段がなく、継続的な更新が難しい。脅威モデルを更新しないと実装が変わるにつれて陳腐化する

- Terraform で管理するものは特になし（Threat Composer は AWS コンソールツール）

#### WAF カスタムルールの活用
> **最善**: カスタムルール + レート制限 + ACP/ATP で高度な攻撃も防御 + 定期的なチューニング  
> **妥協点**: マネージドルールのみで運用し、問題が発生したらカスタムルールを追加  
> **デメリット**: カスタムルールは継続的なチューニング工数が必要。誤検知対応を怠るとビジネスに影響が出る。レート制限の閾値設定を誤ると正常ユーザーをブロックする

- `aws_wafv2_rule_group`（カスタムルール）
- `aws_wafv2_web_acl`（レート制限ルール、ACP/ATP）
- `aws_wafv2_ip_set`

#### DDoS 攻撃 (レイヤー7) の緩和
> **最善**: Shield Advanced + FMS + WAF レート制限 + Route 53 ヘルスチェック連携  
> **妥協点**: Shield Standard (無料) + WAF レート制限のみ  
> **デメリット**: Shield Standard は L3/L4 のみ対応。Shield Advanced は高額（$3,000/月〜）。WAF レート制限だけでは大規模 L7 攻撃に対応できない場合がある

- `aws_shield_protection`（Shield Advanced、リソースごとに有効化）
- `aws_shield_advanced_automatic_response`（自動 DDoS 対応）
- `aws_shield_protection_health_check_association`
- Firewall Manager: `aws_fms_policy` ＊

#### レッドチームの編成
> **最善**: 定期的なペンテスト + Bug Bounty プログラム + 結果を設計にフィードバック  
> **妥協点**: 隔離されたテスト用アカウントを Organizations で用意してペンテスト環境を提供  
> **デメリット**: 人・プロセスが中心で Terraform での強制は不可。ペンテスト結果を修正に結びつける仕組みがないと形骸化する

- Terraform で管理するものは特になし（人・プロセス）
- ペンテスト環境用の隔離アカウント: `aws_organizations_account` ＊

---

## 9. インシデント対応

#### 重大なセキュリティ検出結果への対応
> **最善**: Security Hub → EventBridge → Lambda (自動トリアージ・重要度フィルタリング) + Slack 通知  
> **妥協点**: Security Hub 有効化 + SNS 通知のみ（手動対応）  
> **デメリット**: 通知のみだと対応が遅延する。アラートが多すぎるとアラート疲れで重要な Findings が埋もれる。自動トリアージなしでは全 Findings が同じ優先度に見える

- `aws_securityhub_account`（集約）
- `aws_cloudwatch_event_rule`（EventBridge で Findings をキャッチ）
- `aws_sns_topic` + `aws_sns_topic_subscription`（通知）
- `aws_chatbot_slack_channel_configuration`（Slack 通知）

#### インシデント対応プレイブック
> **最善**: SSM Automation ドキュメントとして実装 + 定期的な演習で有効性を確認  
> **妥協点**: S3 に Markdown/PDF で保管のみ（手動実行）  
> **デメリット**: 文書だけのプレイブックはインシデント時に読んでいる時間がない。自動化されていないプレイブックは手順の抜け・ミスが起きやすい

- `aws_ssm_document`（プレイブックを SSM Automation ドキュメントとして管理）
- `aws_s3_bucket`（プレイブック文書の保存）

#### インシデント机上演習の実施
> **最善**: AWS Jam や CloudSaga を使った定期演習 + 結果を改善サイクルに組み込む  
> **妥協点**: 手動シナリオベースの演習  
> **デメリット**: 技術的な強制手段がなく、実施頻度が属人化しやすい。演習で発見した問題を改善しないと繰り返す

- Terraform で管理するものは特になし（AWS Jam / CloudSaga はコンソール操作）

#### 重要なプレイブックの自動化
> **最善**: Security Hub Automation Rules + EventBridge + Lambda で検出から対応まで自動化  
> **妥協点**: EventBridge で通知だけ自動化し、対応は手動  
> **デメリット**: 自動対応は誤検知時に正常リソースを停止するリスクがある。Lambda の権限が強すぎると攻撃者に悪用される可能性がある。自動化の範囲を慎重に設計する必要がある

- `aws_securityhub_automation_rule`（Security Hub 自動化ルール）
- `aws_cloudwatch_event_rule` + `aws_lambda_function`（EventBridge + Lambda 自動対応）
- `aws_ssm_document` + `aws_ssm_association`（SSM Automation）

#### セキュリティ調査と原因分析
> **最善**: Detective + GuardDuty + Security Hub の連携でグラフ分析  
> **妥協点**: CloudTrail + Athena で手動クエリによる調査  
> **デメリット**: Detective は有効化から数週間でベースラインを構築するため、事後有効化では直近のデータしか使えない。コストが高い。Athena による手動調査は時間がかかりインシデント対応が遅くなる

- `aws_detective_graph`
- `aws_detective_member` ＊（組織メンバーの追加）
- `aws_detective_organization_configuration` ＊

#### ブルーチームの編成
> **最善**: 専任のインシデント対応チーム + オンコール体制 + 定期的なスキルアップ  
> **妥協点**: セキュリティアラートを特定チームにルーティングするだけ  
> **デメリット**: 人的プロセスが中心で技術的な強制手段がない。兼任だとインシデント時の対応速度に限界がある

- Terraform で管理するものは特になし（人・プロセス）

#### 高度なセキュリティ自動化
> **最善**: Step Functions でフォレンジック取得・隔離・通知を全自動化 + 承認ステップを組み込む  
> **妥協点**: Lambda 単体でシンプルな自動対応のみ  
> **デメリット**: 複雑な自動化は誤動作時の影響が大きい。Step Functions の設計・テストに工数がかかる。フォレンジック取得前にリソースを隔離すると証拠が失われる場合がある

- `aws_sfn_state_machine`（フォレンジック収集・隔離のワークフロー）
- `aws_lambda_function`
- `aws_sns_topic`（承認通知）

#### SOAR の活用とチケット管理
> **最善**: 外部 SOAR ツール (Splunk SOAR/Cortex XSOAR) + AWS との Lambda 連携  
> **妥協点**: Lambda + EventBridge で簡易 SOAR を自前構築  
> **デメリット**: 外部 SOAR は高額で導入障壁が高い。自前 SOAR は維持コストが高く、機能拡張に工数がかかる。チケット管理ツールとの連携設定が複雑になりやすい

- Terraform で管理するものは特になし（Splunk SOAR / Cortex XSOAR は外部製品）
- AWS 側連携: `aws_lambda_function` + `aws_cloudwatch_event_rule`

#### 設定不備の自動修正
> **最善**: Config 自動修復 (Auto Remediation) + SSM Automation で即時修正  
> **妥協点**: Config ルールで検出のみ + SNS 通知で手動対応  
> **デメリット**: 自動修復は設定ミスで正常なリソースを変更するリスクがある。修復前のリソース状態を保存しないと原因調査が困難になる。修復が失敗した場合の通知・エスカレーション設計が必要

- `aws_config_config_rule`
- `aws_config_remediation_configuration`（SSM Automation 自動修復）
- `aws_ssm_document`（修復用 Automation ドキュメント）
- `aws_cloudwatch_event_rule` + `aws_sns_topic`（オーナーへの通知）

---

## 10. 回復性

#### レジリエンスの評価
> **最善**: Resiliency Hub でアプリケーションのレジリエンス目標を定義・継続評価  
> **妥協点**: Resiliency Hub の設定 + コンソールで補完（Terraform サポートが限定的）  
> **デメリット**: Terraform の Resiliency Hub サポートが限定的でコンソール作業が残る。RTO/RPO の評価は実際のフェイルオーバーテストが必要で、評価だけでは実態を担保できない

- `aws_resiliencehub_resiliency_policy`
- `aws_resiliencehub_app`（Terraform の Resiliency Hub サポートは限定的。コンソール補完が現実的）

#### マルチ AZ による可用性向上
> **最善**: マルチ AZ + マルチリージョン対応（Active-Active or Active-Passive）  
> **妥協点**: マルチ AZ のみ（同一リージョン内の可用性向上）  
> **デメリット**: マルチ AZ はリージョン障害に対応できない。AZ 間のデータ転送コストが発生する。マルチ AZ 構成でもアプリケーション層のシングルポイントがあると意味がない

- `aws_db_instance`（`multi_az = true`）
- `aws_elasticache_replication_group`（`automatic_failover_enabled = true`）
- `aws_autoscaling_group`（複数 AZ にサブネット指定）
- `aws_lb`（`internal = false` + 複数 AZ）

#### ディザスタリカバリプラン
> **最善**: Pilot Light または Warm Standby 構成 + Route 53 フェイルオーバー + DR テストの定期実施  
> **妥協点**: S3 クロスリージョンレプリケーション + RDS スナップショットコピーのみ（Cold Standby）  
> **デメリット**: Cold Standby は復旧時間が長い (RTO 時間〜日単位)。フェイルオーバーテストを定期的に実施しないと本番で機能しないリスクがある。DR リージョンのコスト管理が別途必要

- `aws_s3_bucket_replication_configuration`（S3 クロスリージョンレプリケーション）
- `aws_rds_cluster`（`global_cluster_identifier` で Aurora Global Database）
- `aws_dynamodb_global_table`
- Route 53 フェイルオーバー: `aws_route53_record`（`failover_routing_policy`）
- `aws_cloudformation_stack_set` ＊（復旧テンプレートの事前展開）

#### ディザスタリカバリの自動化
> **最善**: Elastic Disaster Recovery + Route 53 ヘルスチェック自動フェイルオーバー  
> **妥協点**: Route 53 ヘルスチェック + フェイルオーバーレコードのみ（手動フェイルオーバー）  
> **デメリット**: DRS の初期セットアップが複雑。フェイルオーバー自動化は誤トリガーのリスクがある（ヘルスチェックの閾値設定が重要）。自動フェイルオーバーが起きたことに気づかない場合がある

- `aws_drs_replication_configuration_template`（Elastic Disaster Recovery）
- `aws_route53_health_check` + `aws_route53_record`（フェイルオーバー自動切り替え）

#### カオスエンジニアリングの実施
> **最善**: FIS + Resiliency Hub での定期的な実験 + 結果を設計にフィードバックするサイクルを確立  
> **妥協点**: `aws_fis_experiment_template` を一度だけ実行して弱点を確認  
> **デメリット**: FIS 実験は本番に影響が出る可能性があるため慎重な設計が必要。実験結果を改善に結びつける仕組みがないと形骸化する。実験範囲の設定ミスでサービス障害が発生する可能性がある

- `aws_fis_experiment_template`（FIS 実験テンプレート）

---

> **参考：** Terraform AWS Provider のリソース一覧 → https://registry.terraform.io/providers/hashicorp/aws/latest/docs
