# Config の非準拠を定期リマインドで減らしていく

## こういう場面で困る

コンフォーマンスパックを当てると、ルールが一気に数十〜数百個有効になり、翌日には非準拠が数百件出ている。最初の数日は頑張って直すが、Config のコンソールは見に行かないと見えないので、数週間もすると誰も開かなくなる。「検知はしているのに減らない」で止まる——ルールを大量に入れた組織のほとんどがここで詰まる。

通知経路そのもの（差分だけ通知する・台帳で未解消を追う・N 日ごとにリマインドする・パイプラインの死活は人間のチャンネルに流さない）の作りは [Trusted Advisor のアラートを Slack に通知するアーキテクチャ](TrustedAdvisorアラートのSlack通知.md) と同じでよい。ここでは Config 固有の、**溜まった数百件をどう減らし切るか**だけを書く。

## まず件数をルール単位に畳む

リソース単位の一覧を開くと数百行が並んで心が折れる。Config は最初からルール単位の集計を返せるので、そちらを見る。

```bash
aws configservice describe-compliance-by-config-rule \
  --compliance-types NON_COMPLIANT \
  --query 'ComplianceByConfigRules[*].[ConfigRuleName, Compliance.ComplianceContributorCount.CappedCount]' \
  --output table
```

複数アカウントならアグリゲータ側で同じことをする。

```bash
aws configservice describe-aggregate-compliance-by-config-rules \
  --configuration-aggregator-name org-aggregator \
  --filters ComplianceType=NON_COMPLIANT
```

数百件が「20 ルール」に畳まれる。**減らす単位はルールであってリソースではない。** 1 ルールの対処を決めれば、その下のリソースはまとめて片付く。

## 非準拠は必ず 3 択に倒す

リマインドが機能するのは、届いた非準拠の行き先が決まっているときだけ。「あとで見る」を許すと元の状態に戻る。

1. **直す**——担当を決めて修正する
2. **自動修復に載せる**——毎回同じ手作業で直しているルールは `put-remediation-configuration` で SSM Automation に寄せる。以降はリマインドに出てこない
3. **スコープから外す**——直さないと決めたものを評価対象から外す

### Config には「この 1 件だけ抑止」がない

ここが Security Hub CSPM との一番の違い。Config 側に個別リソースのサプレッション機能はないので、例外化の手段は 2 つになる。

- **ルールのスコープを絞る**：`Scope` の `TagKey` / `TagValue` を使い、「`Exempt=true` が付いたリソースは評価対象外」にする。タグで表現しておくと、例外の一覧を Config のアドバンストクエリでそのまま棚卸しできる
- **Security Hub CSPM 側で抑止する**：Config の評価結果はそこに集約されるので、ダッシュボードの数字から消したいならこちら

どちらの場合も、**ルールごと無効化しない**こと。1 リソースのためにルールを消すと、以降の新規違反も見えなくなる。

## 減らす順序：先に流入を止める

溜まった数百件を全部直そうとすると挫折する。順番を逆にする。

Config のルールには検知（detective）だけでなく、リソースが作られる前に評価するプロアクティブモードがある（一部のマネージドルールが対応）。CloudFormation Hooks と組み合わせると、非準拠になる構成はそもそもデプロイされない。

```
プロアクティブ評価：デプロイ前に弾く   → 新規の非準拠が増えない
検知（detective）：作られた後に気づく → 既存分をリマインドで消化する
```

流入が止まると、週次のリマインドは「増えない前提で減っていくリスト」になり、数字が減ることがチームに見える。逆に流入を止めないまま既存を直しても、翌週には件数が戻っていて続かない。

## 提案するときの言い方

> ルールを何百個入れたこと自体は成果ではない。成果は「非準拠が毎週減っていること」。そのために、届いた指摘の行き先を「直す・自動修復・例外化」の 3 つに決めておき、新しく増える分はデプロイ前に止める。人が張り付いて同じ設定ミスを直し続ける運用にはしない。

## 参考

- [describe-compliance-by-config-rule - AWS CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/configservice/describe-compliance-by-config-rule.html)
- [describe-aggregate-compliance-by-config-rules - AWS CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/configservice/describe-aggregate-compliance-by-config-rules.html)
- [Remediating Noncompliant Resources with AWS Config Rules](https://docs.aws.amazon.com/config/latest/developerguide/remediation.html)
- [Evaluation Mode for AWS Config Rules（プロアクティブ評価）](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config-rules.html)
- [Conformance Packs - AWS Config](https://docs.aws.amazon.com/config/latest/developerguide/conformance-packs.html)
- [Querying the Current Configuration State of AWS Resources](https://docs.aws.amazon.com/config/latest/developerguide/querying-AWS-resources.html)
