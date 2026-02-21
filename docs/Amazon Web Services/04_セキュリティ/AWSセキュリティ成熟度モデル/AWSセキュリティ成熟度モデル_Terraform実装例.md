# AWSセキュリティ成熟度モデル v2 — Terraform リソース早見表

各項目を実装するときに使う主なTerraformリソース名をまとめたもの。
コードは自分で書く前提で、「このへんを調べれば実装できる」レベルの情報。

> `*` は Org 管理アカウント（または委任管理者）が必要なリソース

---

## 1. セキュリティガバナンス

#### セキュリティ連絡先の割当て
- `aws_account_alternate_contact`

#### リージョンの選択と無効化
- `aws_account_region`（オプトインリージョンの無効化・メンバーアカウントで可）
- `aws_organizations_policy` + `aws_organizations_policy_attachment` ＊（SCP によるリージョン制限）

#### コンプライアンスと規制要件の特定
- Terraform で管理するものは特になし（文書管理）
- 強いて言えば文書置き場の `aws_s3_bucket`

#### セキュリティ研修計画
- Terraform で管理するものは特になし（プロセス）

#### セキュアなアーキテクチャ設計
- `aws_wellarchitected_workload`（Well-Architected Review の記録）
- 構成図・設計文書の置き場として `aws_s3_bucket`

#### Infrastructure as Code の活用
- Terraform state 管理: `aws_s3_bucket` + `aws_dynamodb_table`
- デプロイ前チェック: `aws_codecommit_repository` + `aws_codepipeline`（CloudFormation Guard は Terraform 外）

#### タグ付け戦略
- `aws_resourcegroups_group`（タグベースのリソースグループ）
- タグポリシー強制: `aws_organizations_policy`（type = `TAG_POLICY`）＊
- Config でタグ検証: `aws_config_config_rule`（managed rule: `required-tags`）

#### セキュリティタスクの責任分担
- Terraform で管理するものは特になし（RACI はドキュメント）

---

## 2. セキュリティ保証

#### クラウドセキュリティポスチャ管理 (CSPM)
- `aws_securityhub_account`
- `aws_securityhub_standards_subscription`（CIS / AWS基礎ベストプラクティス）
- `aws_securityhub_finding_aggregator`（リージョン横断集約）
- `aws_securityhub_organization_configuration` ＊（組織全体への自動有効化）

#### インベントリと設定モニタリング
- `aws_config_configuration_recorder`
- `aws_config_delivery_channel`
- `aws_config_config_rule`
- `aws_config_organization_managed_rule` ＊（組織全体展開）
- `aws_config_remediation_configuration`（SSM Automation 自動修復）

#### コンプライアンスレポートの作成
- `aws_auditmanager_assessment`
- `aws_auditmanager_framework`
- `aws_auditmanager_control`

#### 監査証拠の収集自動化
- `aws_auditmanager_assessment`（CloudTrail / Security Hub からの自動エビデンス収集）
- `aws_cloudtrail`（エビデンスのソース）

---

## 3. ID とアクセス管理

#### 多要素認証 (MFA) の設定
- MFA 強制ポリシー: `aws_iam_policy`（`aws:MultiFactorAuthPresent` 条件付き Deny）
- `aws_iam_account_password_policy`（パスワードポリシー）
- Cognito MFA: `aws_cognito_user_pool`（`mfa_configuration = "ON"`）

#### ルートの保護
- `aws_cloudwatch_log_metric_filter`（root ログイン検知）
- `aws_cloudwatch_metric_alarm`（root ログイン通知）
- `aws_sns_topic` + `aws_sns_topic_subscription`
- SCP で root 操作拒否: `aws_organizations_policy` ＊

#### ID フェデレーション
- `aws_iam_saml_provider`（アカウントレベル SAML）
- IAM Identity Center（SSO）は Terraform Provider `aws` の `aws_ssoadmin_*` リソース群 ＊
  - `aws_ssoadmin_instance_access_control_attributes`
  - `aws_ssoadmin_permission_set`
  - `aws_ssoadmin_account_assignment`

#### 意図しないアクセス権限の削除
- `aws_accessanalyzer_analyzer`（type = `ACCOUNT` or `ORGANIZATION`）
- 未使用アクセスの検出: `aws_accessanalyzer_analyzer`（type = `ACCOUNT_UNUSED_ACCESS`）

#### 組織のアクセス許可ガードレール
- `aws_organizations_policy`（type = `SERVICE_CONTROL_POLICY`）＊
- `aws_organizations_policy`（type = `RESOURCE_CONTROL_POLICY`）＊
- `aws_organizations_policy_attachment` ＊

#### 一時的な認証情報の使用
- `aws_iam_role` + `aws_iam_instance_profile`（EC2）
- `aws_iam_role`（Lambda / ECS Task Role）
- `aws_secretsmanager_secret` + `aws_secretsmanager_secret_rotation`
- シークレットスキャン CI: `aws_codebuild_project`

#### IMDSv2
- `aws_ec2_instance_metadata_defaults`（アカウントレベルのデフォルト設定）
- `aws_instance`（`metadata_options.http_tokens = "required"`）
- Config ルール検証: `aws_config_config_rule`（managed rule: `ec2-imdsv2-check`）

#### 最小権限の見直し
- `aws_accessanalyzer_analyzer`（CloudTrail ベースのポリシー生成のソース）
- `aws_iam_policy` + `aws_iam_role_policy_attachment`（最小権限ポリシーの管理）
- `aws_codepipeline`（IAM ポリシーの変更フロー自動化）

#### 顧客 ID とアクセス管理(CIAM)
- `aws_cognito_user_pool`
- `aws_cognito_user_pool_client`
- `aws_wafv2_web_acl`（ATP: AccountTakeoverProtection ルール）

#### IAM データ境界の活用
- RCP: `aws_organizations_policy`（type = `RESOURCE_CONTROL_POLICY`）＊
- S3 バケットポリシー条件: `aws_s3_bucket_policy`（`aws:SourceVpc` / `aws:PrincipalOrgID` 条件）
- `aws_iam_policy`（Permission Boundary）

#### IAM ポリシー生成パイプライン
- `aws_codepipeline` + `aws_codebuild_project`（IAM-as-Code パイプライン）
- `aws_lambda_function`（ワイルドカード自動検出・拒否）
- `aws_iam_policy`（IaC 管理）

#### 一時的な昇格アクセスの管理
- `aws_iam_role`（昇格用ロール、最大セッション時間を短く設定）
- `aws_ssoadmin_permission_set`（TEAM ソリューション用）
- 承認フロー: `aws_sfn_state_machine` + `aws_lambda_function`
- 監査: `aws_cloudtrail`

---

## 4. 脅威検出

#### 基本の脅威検出
- `aws_guardduty_detector`
- `aws_guardduty_organization_configuration` ＊（組織全体への自動有効化）
- `aws_sns_topic` + `aws_cloudwatch_event_rule`（Findings 通知）

#### API 呼び出し監査
- `aws_cloudtrail`（`is_organization_trail = true` で組織証跡）
- `aws_s3_bucket` + `aws_s3_bucket_policy`（ログ保存先）
- `aws_cloudtrail_event_data_store`（CloudTrail Lake）
- Config ルール: `aws_config_config_rule`（`cloud-trail-enabled`）

#### 請求アラーム
- `aws_cloudwatch_metric_alarm`（`aws_billing` namespace）
- `aws_budgets_budget`
- `aws_ce_anomaly_monitor` + `aws_ce_anomaly_subscription`

#### 高度な脅威検出
- `aws_guardduty_detector_feature`（Runtime Monitoring / Malware Protection / S3 / RDS / EKS）
- `aws_guardduty_malware_protection_plan`

#### カスタム脅威検出 (SIEM/SecLake)
- `aws_securitylake_data_lake` ＊（Security Lake 組織設定）
- `aws_securitylake_subscriber`
- ログ集約: `aws_cloudwatch_log_group` + `aws_kinesis_firehose_delivery_stream`
- SIEM 自前構築: `aws_opensearch_domain`

#### 脅威インテリジェンスの活用
- `aws_guardduty_threat_intel_set`（カスタム脅威 IP リスト）
- WAF IPセット: `aws_wafv2_ip_set`（IP レピュテーションリスト）
- `aws_wafv2_web_acl`（マネージド IP レピュテーションルール: `AWSManagedRulesAmazonIpReputationList`）

#### VPC フローログの分析
- `aws_flow_log`（VPC / Subnet / ENI 単位で設定）
- 保存先: `aws_cloudwatch_log_group` または `aws_s3_bucket`
- 分析: `aws_athena_workgroup` + `aws_glue_catalog_database`（S3 保存時）

---

## 5. 脆弱性管理

#### インフラの脆弱性管理
- `aws_inspector2_enabler`
- `aws_inspector2_organization_configuration` ＊
- `aws_ssm_patch_baseline` + `aws_ssm_patch_group`
- `aws_ssm_maintenance_window` + `aws_ssm_maintenance_window_task`

#### アプリケーションの脆弱性管理
- `aws_ecr_registry_scanning_configuration`（ECR イメージスキャン）
- `aws_codebuild_project`（SAST/SCA をパイプラインに組み込む）
- `aws_codepipeline`（Critical 脆弱性でのデプロイブロック）

#### セキュリティチャンピオンの配置
- Terraform で管理するものは特になし（人・プロセス）

#### DevSecOps とパイプライン
- `aws_imagebuilder_image_pipeline`（ゴールデンイメージ）
- `aws_imagebuilder_image_recipe`
- `aws_codebuild_project`（SAST/DAST）
- `aws_codepipeline`

#### 脆弱性管理チームの組成
- Terraform で管理するものは特になし（組織・プロセス）
- ダッシュボード用に `aws_cloudwatch_dashboard`

---

## 6. インフラストラクチャー保護

#### 危険な通信ポートのブロック
- `aws_security_group`（`ingress` ルールから 22/3389 を排除）
- Config 自動修復: `aws_config_config_rule`（`restricted-ssh` / `restricted-common-ports`）+ `aws_config_remediation_configuration`

#### ネットワークアクセスの制限
- `aws_security_group`（SGチェーン: ALB SG → Web SG → DB SG）
- `aws_network_acl`
- `aws_fms_policy` ＊（Firewall Manager による組織横断の SG ポリシー）

#### EC2 インスタンスの安全な管理
- `aws_ssm_association`（SSM Agent の設定確認・自動修復）
- `aws_iam_instance_profile`（SSM 用の IAM ロール）
- `aws_ssm_document`（Session Manager のセッション設定）
- `aws_ssm_session_manager_preferences`

#### ネットワークのセグメント化
- `aws_vpc`
- `aws_subnet`（public / private / isolated）
- `aws_nat_gateway`
- `aws_route_table` + `aws_route_table_association`
- `aws_vpc_peering_connection`（ピアリング、業務要件をコメントで文書化）

#### マルチアカウント管理
- `aws_organizations_organizational_unit` ＊
- `aws_organizations_account` ＊
- `aws_controltower_landing_zone` ＊（Control Tower）

#### ゴールデンイメージパイプライン
- `aws_imagebuilder_image_pipeline`
- `aws_imagebuilder_image_recipe`
- `aws_imagebuilder_component`（OS ハードニング手順）
- `aws_imagebuilder_distribution_configuration`
- Config 検証: `aws_config_config_rule`（`approved-amis-by-tag`）

#### マルウェア対策
- `aws_guardduty_detector_feature`（Malware Protection for EC2）
- サードパーティ EDR の展開: `aws_ssm_association`（SSM Distributor でエージェント配布）

#### アウトバウンド通信の制御
- `aws_route53_resolver_firewall_rule_group`（DNS Firewall）
- `aws_route53_resolver_firewall_domain_list`
- `aws_route53_resolver_firewall_rule_group_association`
- `aws_networkfirewall_firewall`（多層検査が必要な場合）
- `aws_networkfirewall_firewall_policy` + `aws_networkfirewall_rule_group`
- `aws_vpc_endpoint`（PrivateLink）

#### ゼロトラストアクセスの実装
- `aws_verifiedaccess_instance`
- `aws_verifiedaccess_trust_provider`（IdP / デバイスコンテキスト）
- `aws_verifiedaccess_group`
- `aws_verifiedaccess_endpoint`

#### 抽象化サービスの利用
- `aws_lambda_function`（サーバーレス移行先）
- `aws_ecs_task_definition`（コンテナ化）
- `aws_api_gateway_rest_api` / `aws_apigatewayv2_api`
- 移行効果測定: `aws_cloudwatch_dashboard`

---

## 7. データ保護

#### パブリックアクセスのブロック
- `aws_s3_account_public_access_block`（アカウントレベル BPA）
- `aws_ec2_image_block_public_access`（AMI BPA）
- `aws_ebs_encryption_by_default`（EBS デフォルト暗号化と合わせて）
- SCP でBPA解除防止: `aws_organizations_policy` ＊

#### データセキュリティポスチャの分析
- `aws_macie2_account`
- `aws_macie2_classification_job`（自動データ機密性検出）
- `aws_macie2_organization_configuration` ＊

#### 保存時のデータ暗号化
- `aws_kms_key` + `aws_kms_alias`
- `aws_kms_key`（`enable_key_rotation = true`）
- `aws_s3_bucket_server_side_encryption_configuration`
- `aws_rds_cluster` / `aws_db_instance`（`storage_encrypted = true`）
- `aws_ebs_encryption_by_default`

#### データのバックアップ
- `aws_backup_vault`
- `aws_backup_plan`
- `aws_backup_selection`
- `aws_backup_vault_policy`（クロスアカウント保護）
- `aws_backup_region_settings`

#### 機密データの検出
- `aws_macie2_account`
- `aws_macie2_custom_data_identifier`（カスタム識別子）
- `aws_macie2_classification_job`

#### 通信の暗号化
- `aws_acm_certificate`（パブリック証明書）
- `aws_acmpca_certificate_authority`（Private CA / 内部通信用）
- `aws_lb_listener`（`protocol = "HTTPS"`）
- `aws_api_gateway_domain_name`

#### 生成 AI データの保護
- `aws_bedrock_guardrail`
- `aws_bedrock_guardrail_version`
- `aws_vpc_endpoint`（Bedrock 用 VPC エンドポイント）

---

## 8. アプリケーションセキュリティ

#### WAF とマネージドルールの活用
- `aws_wafv2_web_acl`（マネージドルール: `AWSManagedRulesCommonRuleSet` 等）
- `aws_wafv2_web_acl_association`（ALB / API Gateway への関連付け）
- Firewall Manager 一括適用: `aws_fms_policy` ＊

#### セキュリティチームの関与
- Terraform で管理するものは特になし（プロセス）
- 設計レビュー記録: `aws_wellarchitected_workload`

#### コード内のシークレット管理
- `aws_secretsmanager_secret`
- `aws_secretsmanager_secret_version`
- `aws_secretsmanager_secret_rotation`
- `aws_ssm_parameter`（Parameter Store SecureString）
- git-secrets / Gitleaks は CI 側の設定（Terraform 外）

#### 脅威モデリングの実施
- Terraform で管理するものは特になし（Threat Composer は AWS コンソールツール）

#### WAF カスタムルールの活用
- `aws_wafv2_rule_group`（カスタムルール）
- `aws_wafv2_web_acl`（レート制限ルール、ACP/ATP）
- `aws_wafv2_ip_set`

#### DDoS 攻撃 (レイヤー7) の緩和
- `aws_shield_protection`（Shield Advanced、リソースごとに有効化）
- `aws_shield_advanced_automatic_response`（自動 DDoS 対応）
- `aws_shield_protection_health_check_association`
- Firewall Manager: `aws_fms_policy` ＊

#### レッドチームの編成
- Terraform で管理するものは特になし（人・プロセス）
- ペンテスト環境用の隔離アカウント: `aws_organizations_account` ＊

---

## 9. インシデント対応

#### 重大なセキュリティ検出結果への対応
- `aws_securityhub_account`（集約）
- `aws_cloudwatch_event_rule`（EventBridge で Findings をキャッチ）
- `aws_sns_topic` + `aws_sns_topic_subscription`（通知）
- `aws_chatbot_slack_channel_configuration`（Slack 通知）

#### インシデント対応プレイブック
- `aws_ssm_document`（プレイブックを SSM Automation ドキュメントとして管理）
- `aws_s3_bucket`（プレイブック文書の保存）

#### インシデント机上演習の実施
- Terraform で管理するものは特になし（AWS Jam / CloudSaga はコンソール操作）

#### 重要なプレイブックの自動化
- `aws_securityhub_automation_rule`（Security Hub 自動化ルール）
- `aws_cloudwatch_event_rule` + `aws_lambda_function`（EventBridge + Lambda 自動対応）
- `aws_ssm_document` + `aws_ssm_association`（SSM Automation）

#### セキュリティ調査と原因分析
- `aws_detective_graph`
- `aws_detective_member` ＊（組織メンバーの追加）
- `aws_detective_organization_configuration` ＊

#### ブルーチームの編成
- Terraform で管理するものは特になし（人・プロセス）

#### 高度なセキュリティ自動化
- `aws_sfn_state_machine`（フォレンジック収集・隔離のワークフロー）
- `aws_lambda_function`
- `aws_sns_topic`（承認通知）

#### SOAR の活用とチケット管理
- Terraform で管理するものは特になし（Splunk SOAR / Cortex XSOAR は外部製品）
- AWS 側連携: `aws_lambda_function` + `aws_cloudwatch_event_rule`

#### 設定不備の自動修正
- `aws_config_config_rule`
- `aws_config_remediation_configuration`（SSM Automation 自動修復）
- `aws_ssm_document`（修復用 Automation ドキュメント）
- `aws_cloudwatch_event_rule` + `aws_sns_topic`（オーナーへの通知）

---

## 10. 回復性

#### レジリエンスの評価
- `aws_resiliencehub_resiliency_policy`
- `aws_resiliencehub_app`（Terraform の Resiliency Hub サポートは限定的。コンソール補完が現実的）

#### マルチ AZ による可用性向上
- `aws_db_instance`（`multi_az = true`）
- `aws_elasticache_replication_group`（`automatic_failover_enabled = true`）
- `aws_autoscaling_group`（複数 AZ にサブネット指定）
- `aws_lb`（`internal = false` + 複数 AZ）

#### ディザスタリカバリプラン
- `aws_s3_bucket_replication_configuration`（S3 クロスリージョンレプリケーション）
- `aws_rds_cluster`（`global_cluster_identifier` で Aurora Global Database）
- `aws_dynamodb_global_table`
- Route 53 フェイルオーバー: `aws_route53_record`（`failover_routing_policy`）
- `aws_cloudformation_stack_set` ＊（復旧テンプレートの事前展開）

#### ディザスタリカバリの自動化
- `aws_drs_replication_configuration_template`（Elastic Disaster Recovery）
- `aws_route53_health_check` + `aws_route53_record`（フェイルオーバー自動切り替え）

#### カオスエンジニアリングの実施
- `aws_fis_experiment_template`（FIS 実験テンプレート）

---

> **参考：** Terraform AWS Provider のリソース一覧 → https://registry.terraform.io/providers/hashicorp/aws/latest/docs
