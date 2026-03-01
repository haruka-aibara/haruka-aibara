<!-- Space: harukaaibarapublic -->
<!-- Parent: Slack -->
<!-- Title: Slack と Teams どっちを使うべきか -->

# Slack と Teams どっちを使うべきか

「Microsoft 365 を契約しているから Teams を使っておけばいい」——それは間違いではないが、開発・技術チームにとって Slack と Teams では生産性に大きな差が出る場面がある。

---

## 結論から

| 状況 | おすすめ |
|---|---|
| 開発チーム中心、OSS・スタートアップ文化 | **Slack** |
| Microsoft 365 が全社標準、非エンジニアが多い | **Teams** |
| エンジニアと非エンジニアが混在する企業 | **両方使い分け**（多い） |

---

## Slack が開発チームに選ばれる理由

### 1. エコシステムが圧倒的に広い

Slack のマーケットプレイスには 6,400 以上のアプリが並ぶ。GitHub・PagerDuty・Datadog・Jira・Sentry・Vercel・AWS など、開発で使うほぼすべてのツールに**一次ソースの公式インテグレーション**がある。

Teams にも連携はあるが、品質・機能・更新頻度で差がある。GitHub との連携は特に顕著で、Slack の GitHub アプリは PR のレビュー依頼・マージ・CI 結果をチャンネルに流すだけでなく、Slack から直接 `/github` コマンドで Issue を作成・クローズできる。

### 2. API が使いやすく、カスタムボットを作りやすい

Slack API は設計がシンプルで、Webhook URL を払い出せば 10 行未満のコードでメッセージを送れる。社内アラート・デプロイ通知・定期レポートの Bot を作るときに、Slack は「明らかに開発者向けに設計されている」と感じる。

```bash
# 最も簡単な Slack 通知（Incoming Webhook）
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"デプロイ完了 :white_check_mark:"}' \
  https://hooks.slack.com/services/xxx/yyy/zzz
```

Teams の Webhook も存在するが、フォーマット（Adaptive Cards）の複雑さと制約が多く、メンテナンスコストが高い。

### 3. チャンネルの設計自由度

Teams の「チーム」→「チャンネル」という 2 層構造は、プロジェクトをまたいだ会話をしにくい。例えば「全エンジニアが見る #dev-general」というチャンネルを Teams で作ろうとすると、どの「チーム」に属するかという問題が生じる。

Slack はフラットなチャンネル設計なので、`#dev-general`・`#pj-xxx`・`#alert-prod` のような横断チャンネルを自然に作れる。

### 4. 検索の精度と速度

過去のやりとりを掘り起こす作業は日常茶飯事。Slack の全文検索は `in:#channel from:@user has:link` のような絞り込みができ、コードスニペットや添付ファイルの中身まで検索できる。Teams の検索は検索範囲の制御が弱く、「あの会話どこだっけ」が Teams ではより迷子になりやすい。

### 5. スタートアップ・OSS コミュニティとの外部連携

GitHub・Figma・Linear・Notion など、ツールの公式コミュニティや外部パートナーが Slack で動いていることが多い。OSS のサポートチャンネル、ベンダーとの共有ワークスペース（Slack Connect）も Slack が主流。Teams で同等のことをするのは相手が M365 環境にいないと難しい。

---

## Teams が勝る場面

公平に言うと、Teams が向いている場面もある。

- **Microsoft 365 環境に深く統合している**: SharePoint・Outlook・OneNote との連携は Teams のほうが圧倒的に自然
- **ビデオ会議が中心**: Teams の会議機能・録画・トランスクリプトは Slack より成熟している
- **全社標準で非エンジニア部門も使う**: ライセンス的に M365 に含まれているため追加コストがかからない
- **大規模エンタープライズのセキュリティ要件**: Microsoft Purview との統合、条件付きアクセス、DLP など

---

## 「なぜ Teams じゃダメなの？」と言われたら

| よく言われること | 実態 |
|---|---|
| 「M365 に含まれてるからタダじゃん」 | Slack の年間コストより、開発者が Teams で失う生産性のほうがコストが高いケースがある |
| 「セキュリティが心配」 | Slack Enterprise Grid は SOC 2 Type II、ISO 27001 取得済み。企業向けには遜色ない |
| 「ひとつのツールに統一したい」 | ビデオ会議は Teams、テキスト・Bot・通知は Slack、という分業が現実的にはよく機能する |

---

## 市場の実態

エンジニア・開発チームの Teams より Slack の利用率は **54% 高い**（2025年時点）。スタートアップ・SaaS 企業・テック系は Slack が事実上の業界標準になっている。採用面でも「Slack を使える開発者」は多いが、「Teams の Bot 開発に慣れている開発者」は少ない。
