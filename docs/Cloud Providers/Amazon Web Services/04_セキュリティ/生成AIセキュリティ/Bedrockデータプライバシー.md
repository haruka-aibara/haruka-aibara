<!-- Space: harukaaibarapublic -->
<!-- Parent: 生成AIセキュリティ -->
<!-- Title: Bedrock データプライバシー -->

# Bedrock データプライバシー

「Bedrock に社内データを入力して大丈夫ですか？ AWS に学習されませんか？」——経営や法務からこの質問が来たとき、技術的な正しさを持って答えられる状態にしておく必要がある。

---

## AWSはプロンプトを学習に使わない

**AWS の明示的なコミットメント：** Amazon Bedrock は、顧客のプロンプト・レスポンス・ファインチューニング用データセットをファウンデーションモデルの訓練・改善に使用しない。Amazon 自身のモデルも、Anthropic・Meta など Bedrock 経由でアクセスするサードパーティモデルも同様。AWS はサードパーティモデルプロバイダーに顧客データを共有しない。

この内容は公式ドキュメントでの記載にとどまらず、[Serverless Third-Party Models のサービス利用規約](https://aws.amazon.com/legal/bedrock/third-party-models/) に法的コミットメントとして記載されている。「ドキュメントにそう書いてある」ではなく「契約上の約束」として社内に説明できる。

さらに確実にしたい場合は **AWS Data Processing Addendum（DPA）** を締結する。GDPR 上のデータ処理契約で、AWS がデータプロセッサーとして負う義務を文書化したもの。

---

## データの暗号化

| 対象 | 既定 | オプション |
|---|---|---|
| 転送中（In-transit） | TLS 1.2 以上 | TLS 1.3 |
| 保存時（At-rest）— 推論ログ | AWS 管理 KMS キー | カスタマー管理キー（CMK） |
| 保存時 — ファインチューニング成果物 | AWS 管理 KMS キー | CMK |
| 保存時 — Knowledge Base ベクトルストア | AWS 管理 KMS キー | CMK |

KMS CMK を使うと、キーの削除でデータを論理的に破棄できる。規制上の要件がある場合は CMK を検討する。

---

## データ残留とクロスリージョン推論の落とし穴

**デフォルト**では、Bedrock API を呼び出したリージョンでプロンプトが処理される。東京リージョンで呼べば東京で処理される。

問題が起きるのは **クロスリージョン推論プロファイル**（cross-region inference profile）を使うとき。クロスリージョン推論プロファイルを使うと、負荷分散のために別リージョンでも推論が実行される可能性がある。たとえば「US」リージョングループを選ぶと、us-east-1・us-east-2・us-west-2 のどこかで処理される可能性がある。

**GDPR や国内データ規制への影響：** GDPR では「データの処理」も対象。プロンプトが EU 外のリージョンで処理されれば、EU 外への個人データ移転として扱われる可能性がある。「保存しない」では言い訳にならない場合がある。

```bash
# 東京リージョン（ap-northeast-1）に固定する例
# クロスリージョン推論プロファイルを使わず、リージョナルエンドポイントを直接使う
aws bedrock-runtime invoke-model \
  --model-id "anthropic.claude-3-5-sonnet-20241022-v2:0" \
  --region ap-northeast-1 \
  --body '{"messages":[{"role":"user","content":[{"type":"text","text":"Hello"}]}]}' \
  output.json
```

厳格なデータ残留要件がある場合：クロスリージョン推論プロファイルは使わない、リージョナルエンドポイントを明示的に指定する。

---

## コンプライアンス認証

| 認証・規制 | Bedrock の状況 |
|---|---|
| ISO 27001 / 27017 / 27018 / 27701 | 取得済み |
| SOC 1 / 2 / 3 | 取得済み |
| HIPAA | 適格（BAA 締結が必要） |
| GDPR | DPA 締結でデータプロセッサーとして対応 |
| PCI DSS Level 1 | 取得済み |
| FedRAMP High | GovCloud (US-West) で取得済み |

HIPAA 対応が必要なシステムで Bedrock を使う場合、**AWS との Business Associate Agreement（BAA）** の締結が必要。BAA なしに PHI（保護医療情報）を Bedrock に送ることは HIPAA 違反になる可能性がある。

---

## GDPR の「忘れられる権利」への対応

Knowledge Base（RAG）を使っている場合、GDPR の忘れられる権利（削除要求）への対応手順：

```
1. S3 データソースから対象ドキュメントを削除
2. Knowledge Base の同期（Sync）を実行
   → ベクトルストアから該当ベクトルが削除される
3. Knowledge Base の S3 データソースの削除ログを保持
   （削除した事実の証拠として）
```

```bash
# Knowledge Base の再同期を実行
aws bedrock-agent start-ingestion-job \
  --knowledge-base-id kb-xxxxxxxxxx \
  --data-source-id ds-xxxxxxxxxx
```

文書が削除されてから次の Sync が走るまでの間は、古いベクトルが残る。定期的な Sync スケジュールと、削除要求から完全消去までの SLA を定義しておく。

---

## ビジネス側への伝え方

| 技術的な言い方 | ビジネス側に刺さる言い方 |
|---|---|
| AWS はプロンプトを学習に使わない | 「AWS に学習されませんか？」→ 規約上の法的コミットメントがある。「書いてあるだけ」ではなく契約として担保されている |
| CMK で暗号化する | 規制当局に監査された場合、キー管理の証跡が必要になる |
| GDPR DPA を締結する | EU 域内の個人情報を扱う場合、AWS をデータプロセッサーとして正式に位置づける契約が必要 |
| クロスリージョン推論は使わない | 「データは日本国内のみで処理」を約束している場合、クロスリージョン推論をオンにするとその約束が破れる |

---

## 参考

- [Amazon Bedrock Security and Privacy](https://aws.amazon.com/bedrock/security-compliance/)
- [Amazon Bedrock — Data protection](https://docs.aws.amazon.com/bedrock/latest/userguide/data-protection.html)
- [Serverless Third-Party Models — 利用規約](https://aws.amazon.com/legal/bedrock/third-party-models/)
- [Securing Amazon Bedrock cross-Region inference: Geographic and global](https://aws.amazon.com/blogs/machine-learning/securing-amazon-bedrock-cross-region-inference-geographic-and-global/)
- [Implementing Knowledge Bases for Amazon Bedrock in support of GDPR right to be forgotten](https://aws.amazon.com/blogs/machine-learning/implementing-knowledge-bases-for-amazon-bedrock-in-support-of-gdpr-right-to-be-forgotten-requests/)
- [Amazon Bedrock Compliance Validation](https://docs.aws.amazon.com/bedrock/latest/userguide/compliance-validation.html)
