# Trusted Advisor のアラートを Slack に通知するアーキテクチャ

## こういう場面で困る

Trusted Advisor は「コンソールを開いた人しか気づかない」サービス。公開設定になった S3 バケットや漏洩したアクセスキーをチェックが検出して WARN / ERROR になっていても、誰かが見に行くまで放置される。月イチの棚卸しで開いて「これいつから赤かったんだ」となるのが典型的な失敗パターン。

だから Slack に流したくなる。定番として紹介されるのは EventBridge でイベントを受けて Slack に流す構成だが、結論から言うとこの記事では**イベント駆動を使わない**。EventBridge 連携が破綻する理由と、イベント駆動そのものが要らない理由を先に書く。

## 定番の EventBridge 構成がなぜダメか

Trusted Advisor は EventBridge（us-east-1 のみ）に `Trusted Advisor Check Item Refresh Notification` というイベントを流せる。これを SNS → Slack に直結する構成が定番として紹介されがちだが、問題が 2 段階ある。

### 第 1 段階：そのまま流すと通知が爆発する

イベントはチェック単位ではなく、**チェック項目＝リソース単位**で出る。公式のイベント例を見ると `detail.check-item-detail` に個別リソースの情報が入っていて、フラグが立ったリソース 1 件につき 1 イベント。つまり有効化直後のリフレッシュで既存の指摘（開いた SG が 30 個あれば 30 通）が一斉に流れ込む。さらに「ステータスが変化した時だけイベントが出る」という保証はドキュメントのどこにもなく、EventBridge は at-least-once 配信なので、同じリソースの同じ WARN が週次リフレッシュのたびに再通知される前提になる。1〜2 週間でチャンネルごとミュートされて終わる。

### 第 2 段階：重複排除を作り込んでも、イベント駆動自体が割に合わない

じゃあ Lambda と DynamoDB で重複排除すればいいかというと、今度は複雑さが釣り合わない。冷静に「即時」の正体を分解すると：

**検出遅延 = チェックのリフレッシュ間隔 + 通知経路の遅延**

Trusted Advisor の自動リフレッシュは週次程度。イベント駆動が縮めるのは後者（通知経路）だけで、ポーリングと比べた差はポーリング間隔 1 個分（後述の構成なら 15〜60 分）に過ぎない。**週次のリフレッシュの上に乗った「秒で届く」に意味はない。** 本当に検出遅延を詰めたければ `RefreshTrustedAdvisorCheck` API の定期実行（チェックごとに最短 5 分間隔）でリフレッシュ間隔そのものを制御するしかなく、それはスケジュール駆動の仕事。つまりスケジューラがどのみち主役になる。

一方、イベントを受けるために背負い込むものは多い：

- **us-east-1 制約**：グローバルサービスなのでイベントは us-east-1 にしか流れない。別リージョンにルールを作って「何も来ない」で数時間溶かす定番のハマり
- **チェック名の文字列フィルタ**：イベントにカテゴリ情報がないためルールはチェック名の列挙になる。チェック名が改名されたら通知は黙って止まる
- **ID 空間の分断**：イベントは旧 Support API 系の識別子（`uuid` / `check-item-detail`）で、新 Trusted Advisor API の recommendation resource ARN を持っていない。台帳やネイティブ除外と繋ぐには checkArn 経由の解決処理と、反映タイミング差へのフォールバックが要る
- **ベストエフォート発行**：Trusted Advisor から EventBridge への発行は公式に「ベストエフォート」。頻繁に落ちるわけではないが、発行されなかったイベントには痕跡がなく、**落ちたことを検知する手段がない**。結局「見逃しゼロ」の担保には定期ポーリングが別途必要になる

見逃しゼロの統制をポーリングで担保するなら、イベントレーンは「ポーリング間隔 1 個分だけ早い、信頼できない近道」でしかない。耐荷重でない部品がコードの大半を占める設計は捨てる。**ポーリングに一本化すると、この問題群は解決されるのではなく消滅する。**

（イベント駆動が正解になるのは、人間への通知ではなく自動修復——漏洩アクセスキーの検出から数秒で deny ポリシーを当てる類——を作る場合。それはこの記事のスコープ外）

## 対象はセキュリティカテゴリだけに絞る

対象を先に決める。この構成で見るのは**セキュリティカテゴリのチェックだけ**。コストや耐障害性の指摘は「今すぐ人が動く」性質のものではなく、同じ通知経路に混ぜるとセキュリティ通知の信頼度を下げる。それらはコンソールで棚卸しのときに見れば足りる（必要になったら同じ仕組みを別チャンネル・別頻度で複製すればいい）。

新 Trusted Advisor API はカテゴリ（pillar）でのフィルタをサポートしているので、対象の絞り込みはチェック名の列挙ではなく `pillar=security` の宣言 1 つで済む。新しいセキュリティチェックが追加されても自動で対象に入る。うるさいチェックが混ざっていたら、そのチェックのリソースを除外（exclusion）で削る。

## 理想状態の定義：どういう場合に、どのくらいの通知か

アラート疲れを防ぐ原則はひとつ。**通知するのは「人が対応すべき新規の検出」だけ。再通知は意図したリマインドとしてだけ行う。** それ以外は一切送らない。

| 通知の種類 | 対象 | 頻度・遅延の理想 | 判断基準 |
|---|---|---|---|
| 新規検出の通知 | WARN / ERROR の**新規検出** | 新規発生時のみ。検出遅延の上限 = リフレッシュ間隔 + ポーリング間隔 | 対応が必要な変化か？ |
| リマインド | 未解消のまま N 日経過した項目 | 解消されるまで N 日ごと（例：3 日） | 放置を検出できるか？ |
| 通知しない | 変化のない項目、OK 復帰の通知、定期サマリ、セキュリティ以外のカテゴリ | 0 | — |

ポイントは 2 つ。

**再通知を「事故」ではなく「設計されたリマインド」にする。** 同じ項目の通知が来るのは「N 日経っても未解消」という意味を持ったときだけ。リマインドが増えてきたらそれ自体が「対応が回っていない」というシグナルになる。リスク受容した項目は Trusted Advisor ネイティブの除外（exclusion）に落としてリマインド対象から外し、自前で持つのは除外の期限管理だけにする（無期限の受容は作らない。期限が来たら include に戻して受容の再評価を強制する）。

**パイプラインの死活確認を Slack に混ぜない。** 「新規のときだけ通知」の設計は、静かなチャンネルが「全部正常」なのか「パイプラインが 1 ヶ月前から壊れている」のか区別できないという構造的な弱点を持つ。だからといって定期サマリを人間のチャンネルに流すのは、人間を監視装置として使うことになる。死活は機械に見させる：Lambda のエラーと実行回数に CloudWatch アラームを張り、「エラーが出た」「スケジュールどおり実行されていない」を運用アラートとして拾う。人間のチャンネルにはセキュリティの検出だけが流れる状態を守る。

## アーキテクチャ：スケジュール駆動 1 本

```
EventBridge Scheduler（15〜60 分ごと）
  → Lambda:（検出遅延を詰めるなら RefreshTrustedAdvisorCheck →）
     ListRecommendations(pillar=security) → ListRecommendationResources
     → 台帳（DynamoDB）と差分
       ├ 新規の WARN/ERROR → Slack に通知＋台帳登録
       ├ 未解消かつ最終通知から N 日経過 → リマインド
       └ 解消を検出 → 台帳クローズ（通知はしない）

CloudWatch アラーム（死活確認）
  ├ Lambda の Errors > 0
  └ Lambda の Invocations がスケジュール期待値を下回る
```

Lambda 1 本とスケジュール 1 本だけ。Slack への投稿は Incoming Webhook でも、SNS + Amazon Q Developer in chat applications（旧 AWS Chatbot）経由でもいい。

この構成の性質：

- **最初から ARN ネイティブ**。新 Trusted Advisor API（`ListRecommendations` / `ListRecommendationResources`）だけで完結し、識別子は recommendation resource ARN に一本化。旧 ID 空間との橋渡しが存在しない
- **除外との統合が素直**。`exclusionStatus` で受容済みリソースを差分から外し、受容の操作も `BatchUpdateRecommendationResourceExclusion`（ARN を渡す）で行える。コンソールにも「除外済み」として見える
- **見逃しの上限が設計値になる**。何かを取りこぼしても最大 1 ポーリング間隔遅れで必ず拾う。自前バグ（ロジックミス、権限不足）もポーリングのたびに再試行される
- **検出遅延がコントローラブル**。対象チェックの `RefreshTrustedAdvisorCheck` を定期実行すれば、遅延上限 ≒ リフレッシュ実行間隔 + ポーリング間隔として自分で決められる。「AWS がいつリフレッシュするか」への依存が消える

### 通知台帳（DynamoDB）の設計

主キーは recommendation resource ARN。属性に初回検出日時・初回通知日時・最終リマインド日時・状態（未解消 / 解消）を持つ。

- **導入時のベースライン取り込み**を忘れない。初回実行で既存の指摘を「通知済み」として台帳登録すれば、初回爆発はゼロ。既存分は導入時に一度だけ一覧を出して棚卸しし、以降はリマインドに乗せて消化していく
- resource の ID がリフレッシュをまたいで同一である保証は明文化されていないので、`awsResourceId` ベースで重複エントリを潰す処理を入れておくと堅い

### チャンネルを分岐したくなったら（タグ → チャンネル振り分け）

「このタグが付いたリソースの指摘はこのチームのチャンネルへ」という振り分けは可能だが、Trusted Advisor 自身はタグを返さない（`RecommendationResourceSummary` にタグのフィールドはなく、`metadata` はチェックごとに中身がバラバラ）。通知を出す直前にタグを解決する 1 ホップを足す。

タグ解決は **AWS Config の advanced query**（`SelectResourceConfig`）を使う。ただし「1 本の万能クエリでサービス横断に引ける」ほど甘くはない。ID 空間が両側で揺れているからだ：

- **TA 側の `awsResourceId` は仕様化されていない**。API リファレンスは「AWS resource identifier。一部チェックには無い」としか言っておらず、中身は SG ID（sg-…）、バケット名、アクセスキー ID（AKIA…）とチェックごとにバラバラ
- **Config 側も一様ではない**。`resourceId` は SG なら sg-xxx、S3 ならバケット名だが、IAM ユーザーは内部 ID（AIDA…）で名前は `resourceName` 側、RDS は DbiResourceId で DB 識別子は `resourceName` 側
- 型を絞らないクエリは、別リソースタイプの同名リソース（同名の Lambda と IAM ロールなど）を引いて誤ったタグで振り分ける危険がある

なので実装は「チェック → Config リソースタイプ」の小さい対応表を持ち、**型で絞って引く**：

```sql
SELECT resourceId, resourceName, tags
WHERE resourceType = 'AWS::EC2::SecurityGroup'
  AND (resourceId = 'sg-0123456789abcdef0' OR resourceName = 'sg-0123456789abcdef0')
```

対応表と聞くとチェックごとの作り込みが復活するようだが、セキュリティカテゴリで実際にフラグが立つチェックは限られるので表は小さい。作る前に `ListRecommendationResources` の実データをダンプして `awsResourceId` の中身を目視すること——仕様がない以上、実測が先、実装が後。

Resource Groups Tagging API でも引けるが、あちらは ARN が必須で `awsResourceId` から ARN を組み立てる処理をサービスごとに書くことになるので、Config が無い場合の次善策。

設計上の必須事項と導入条件：

- **フォールバックチャンネルは必須**。対応表に載らないクラスは必ず存在する：`awsResourceId` が無いアカウントレベルの指摘（ルート MFA 等）、Config が記録しないもの（アクセスキー単体。Config の IAM 記録対象は user / group / role / policy）、タグ未付与のリソース。そして**振り分け不能なものは、だいたい振り分けるべきでないもの**——漏洩アクセスキーを特定チームのチャンネルに送るのは間違いで、中央のセキュリティチャンネル直行が正解。不能クラスと不要クラスがほぼ一致するので、フォールバック設計は妥協ではなく本来の姿
- タグ解決が走るのは新規検出の通知時だけなので、コストは実質ゼロ
- **この分岐が価値を持つ条件は 2 つ**：同一アカウントに複数の所有チームが同居していること、タグ付けが強制されていること。どちらかが欠けると、ほとんどの通知がフォールバックに落ちる振り分け装置ができるだけ。タグの整備が先、分岐は後。単一チームで見ているうちはチャンネル 1 本のままが正解

### まず小さく始めるなら

この Lambda を**1 日 1 回・新規検出の通知だけ**で動かすのが最初の 1 歩。差分計算と台帳だけ作れば、理想状態の 8 割（見に行かなくても届く・アラート疲れしない）が手に入る。放置が気になったらリマインドを、検出遅延を詰めたくなったら高頻度化と `RefreshTrustedAdvisorCheck` を足す。

どうしてもコードを書かずに今日始めたいなら EventBridge → SNS → Chatbot の直結もあるが、リソース単位の重複と初回爆発を許容する一時運用と割り切り、恒久構成にしないこと。

## 前提条件とハマりどころ

- **Business / Enterprise On-Ramp / Enterprise のサポートプランが必要**。Basic / Developer ではチェック自体がほぼ動かない
- **チェックの自動リフレッシュは週次程度**。「発生した瞬間」ではなく「リフレッシュで検出された瞬間」の通知であり、遅延を詰めるにはリフレッシュの定期実行が必要（チェックごとに最短 5 分間隔）。リアルタイム検知が本当の要件なら AWS Config ルールや GuardDuty の領分。Trusted Advisor 通知は「定期健診の結果を、見に行かなくても届くようにする」ものと位置づける
- SNS + Chatbot 経由で投稿する場合、SNS トピックを KMS 暗号化しているとキーポリシーで発行元サービスの許可が要る（無通知でハマる）

## 提案するときの言い方

> Trusted Advisor は AWS が自動でやってくれる設定診断だが、結果は誰かが見に行かないと気づけない。これを「セキュリティの指摘だけが、検出から 1 時間以内に届き、直るまで数日ごとに催促が来る」Slack 通知にする。それ以外は一切流さないので、来た通知は必ず対応対象——アラート疲れで形骸化しないし、放置も自動で検出される。追加コストは Lambda と DynamoDB でほぼゼロ（サポートプランは既存契約の範囲）。

## 参考

- [AWS Trusted Advisor - AWS Support](https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html)
- [Trusted Advisor API Reference（ListRecommendations 等）](https://docs.aws.amazon.com/trustedadvisor/latest/APIReference/Welcome.html)
- [ListRecommendationResources - AWS Trusted Advisor API](https://docs.aws.amazon.com/trustedadvisor/latest/APIReference/API_ListRecommendationResources.html)
- [How to exclude resources from AWS Trusted Advisor reports using Trusted Advisor API - AWS re:Post](https://repost.aws/articles/AR2RklKWyrTRGTCaZZu11dPw/how-to-exclude-resources-from-aws-trusted-advisor-reports-using-trusted-advisor-api)
- [RefreshTrustedAdvisorCheck - AWS Support API Reference](https://docs.aws.amazon.com/awssupport/latest/APIReference/API_RefreshTrustedAdvisorCheck.html)
- [SelectResourceConfig - AWS Config API Reference](https://docs.aws.amazon.com/config/latest/APIReference/API_SelectResourceConfig.html)
- [Example Queries - AWS Config](https://docs.aws.amazon.com/config/latest/developerguide/example-query.html)
- [Monitoring AWS Trusted Advisor check results with Amazon EventBridge - AWS Support](https://docs.aws.amazon.com/awssupport/latest/user/cloudwatch-events-ta.html)
- [AWS Trusted Advisor events - Amazon EventBridge](https://docs.aws.amazon.com/eventbridge/latest/ref/events-ref-trustedadvisor.html)
- [Tutorial: Get started with Slack - Amazon Q Developer in chat applications](https://docs.aws.amazon.com/chatbot/latest/adminguide/slack-setup.html)
- [aws-samples/aws-trusted-advisor-scheduled-refresh - GitHub](https://github.com/aws-samples/aws-trusted-advisor-scheduled-refresh)
