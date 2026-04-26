<!-- Space: harukaaibarapublic -->
<!-- Parent: 検知と可視化 -->
<!-- Title: Security Hub FSBP コントロールの優先順位の付け方 -->

# Security Hub FSBP コントロールの優先順位の付け方

Security Hub を有効化した直後、画面には「FAILED: 500件以上」という数字が並ぶ。何から手をつければいいのか途方に暮れる——これが Security Hub あるあるだ。

FSBP（Foundational Security Best Practices）は AWS が定義したセキュリティ基準で、コントロール数は 300 を超える。全部を順番に直していくのは現実的ではない。「今のフェーズで何が最も効いて、何は後回しでいいか」を判断できることが、Quick Wins を効率よく進める鍵になる。

---

## まず数字より「クリティカル」と「HIGH」だけ見る

Security Hub のコントロールには重大度（CRITICAL / HIGH / MEDIUM / LOW）がついている。

```bash
# CRITICAL・HIGH の FAILED コントロールだけ抽出
aws securityhub get-findings \
  --filters '{"SeverityLabel": [{"Value": "CRITICAL", "Comparison": "EQUALS"}, {"Value": "HIGH", "Comparison": "EQUALS"}], "ComplianceStatus": [{"Value": "FAILED", "Comparison": "EQUALS"}]}' \
  --query 'Findings[*].[Title, SeverityLabel, ProductFields.ControlId]' \
  --output table
```

MEDIUM 以下は後回しでいい。まず CRITICAL と HIGH をゼロにすることが Quick Wins の現実的なゴール。

---

## Quick Wins フェーズで確実に直すべきコントロール

### S3 系（データ漏洩リスクが直結）

| コントロール | 内容 | 対処 |
|---|---|---|
| S3.1 | S3 パブリックアクセスブロックが未設定 | アカウントレベルの Block Public Access を ON |
| S3.2 | バケットにパブリック読み取りポリシーがある | バケットポリシーを確認・修正 |
| S3.5 | S3 は SSL のみ要求していない | バケットポリシーに `aws:SecureTransport` 条件を追加 |

### IAM 系（認証・認可の基礎）

| コントロール | 内容 | 対処 |
|---|---|---|
| IAM.1 | IAM ポリシーが直接ユーザーにアタッチされている | グループ・ロール経由に変更 |
| IAM.4 | ルートアカウントのアクセスキーが存在する | 即時削除 |
| IAM.6 | ルートアカウントに MFA がない | 即時設定（MFA デバイス推奨） |
| IAM.9 | MFA が有効でないルートアカウントがある | IAM.6 と同じ対処 |
| IAM.28 | アクセスアナライザーが有効でない | リージョンごとに有効化 |

### EC2 系（攻撃面の削減）

| コントロール | 内容 | 対処 |
|---|---|---|
| EC2.2 | セキュリティグループが 0.0.0.0/0 で SSH 許可 | IP 制限または SSM Session Manager に移行 |
| EC2.3 | セキュリティグループが 0.0.0.0/0 で RDP 許可 | EC2.2 と同じ対処 |
| EC2.8 | IMDSv1 が有効なインスタンスがある | `--http-tokens required` に変更（別記事参照） |

### CloudTrail / GuardDuty 系（ログ・検知の基盤）

| コントロール | 内容 | 対処 |
|---|---|---|
| CloudTrail.1 | CloudTrail が有効でない | 組織レベルの証跡を有効化 |
| CloudTrail.2 | CloudTrail ログのファイル検証が無効 | `--enable-log-file-validation` を追加 |
| GuardDuty.1 | GuardDuty が有効でない | 全リージョンで有効化 |

---

## 優先順位の付け方：3 つの軸で評価する

1. **漏洩インパクト**：データが外に出る可能性があるか（S3 パブリック公開は最優先）
2. **横展開リスク**：攻撃者がアカウント全体を乗っ取れるか（ルート MFA・IAM アクセスキーは即対応）
3. **対処の簡単さ**：1コマンドで直るか、アプリに影響するか（S3 Block Public Access はアカウントレベルなら即適用可能）

```
漏洩インパクト × 横展開リスク が高い → 今すぐ
対処が簡単 → 今すぐ（コスパ最高）
アプリへの影響調査が必要 → 計画して対応
```

---

## 「適用除外」の使い方

Security Hub には「対応不要」とマークできるサプレッション機能がある。コントロールをスコアから除外できる。

```bash
# 特定のコントロールをサプレッションに設定
aws securityhub update-findings \
  --filters '{"ProductArn": [{"Value": "arn:aws:securityhub:ap-northeast-1::product/aws/securityhub", "Comparison": "EQUALS"}], "Id": [{"Value": "finding-id-here", "Comparison": "EQUALS"}]}' \
  --note '{"Text": "レガシーシステムのため対応不可。代替コントロールあり", "UpdatedBy": "security-team"}' \
  --record-state SUPPRESSED
```

乱用すると「スコアが高いのに実態はボロボロ」な状態になる。正当な理由（代替コントロールあり / ビジネス上の例外）以外は使わない。

---

## スコアの読み方

Security Hub のスコアは「PASSED / (PASSED + FAILED)」の割合。**100% を目指す必要はない**。

- **Quick Wins フェーズの現実的な目標**: CRITICAL・HIGH の FAILED をゼロにする
- **Foundational フェーズの目標**: 全体スコア 80% 以上
- **Efficient フェーズ**: カスタムコントロール・自動修復を組み込み 90% 以上を維持

スコアが上がっても、CRITICAL の FAILED が 1 件でも残っていれば意味がない。重大度の高いものを先に潰すのが正解。

---

## 組織全体のスコアを一括確認する

Organizations で複数アカウントある場合、委任管理者（Security Hub 管理アカウント）から全アカウントの集計を見られる。

```bash
# 管理アカウントから全アカウントの標準スコアを取得
aws securityhub list-standards-control-associations \
  --security-control-id "IAM.6" \
  --query 'StandardsControlAssociationSummaries[*].[StandardsArn, AssociationStatus]' \
  --output table
```

個々のアカウントを1つずつ確認する必要がなく、一括でどのアカウントが問題かを把握できる。

---

## 参考

- [AWS Foundational Security Best Practices コントロール一覧](https://docs.aws.amazon.com/securityhub/latest/userguide/fsbp-standard.html)
- [Security Hub のスコアの計算方法](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-results.html)
- [コントロールの無効化とサプレッション](https://docs.aws.amazon.com/securityhub/latest/userguide/controls-findings-create-update.html)
