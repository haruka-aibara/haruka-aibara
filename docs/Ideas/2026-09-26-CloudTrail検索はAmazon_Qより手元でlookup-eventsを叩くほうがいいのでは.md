tags: aws, cloudtrail, amazon-q, ai, cli

# CloudTrail 検索は Amazon Q より手元で lookup-events を叩くほうがいいのでは

Amazon Q（コンソール）と CloudTrail が統合され、自然言語で CloudTrail を検索できるようになった。
ただ、手元の AI に `aws cloudtrail lookup-events` を組み立てさせて叩くほうが、developer 目線では使いやすい気がしている。

## 手元でやるほうがよさそうな理由

- 投げたコマンドが残るので、何を検索したか後から追える。再実行もできる
- `jq` で絞る・集計する・他のログと突き合わせる、までそのまま続けられる
- コンソールを開いて画面遷移しなくて済む。普段の作業（ターミナル・エディタ）から離れない
- どのツールの AI でもよい。特定サービスの UI に縛られない

## 気になる点（未確認）

- `lookup-events` は直近 90 日の管理イベントだけが対象で、検索条件（`--lookup-attributes`）も 1 つずつしか指定できない。データイベントや長期の検索は CloudTrail Lake か Athena が要る
- API のレート制限が厳しいので、広い範囲を舐めると遅い
- Amazon Q 側が CloudTrail Lake の SQL 生成まで面倒を見てくれるなら、そこは Amazon Q が有利かもしれない
- 手元で叩く場合、AI に渡す認証情報の権限を読み取りに絞っておく

どちらが上というより、「ちょっと見る」は Amazon Q、「調べて残す・加工する」は手元、と分けるのが妥当かもしれない。
実際に両方で同じ調査をしてみて比べる。
