<!-- Space: harukaaibarapublic -->
<!-- Parent: Slack -->
<!-- Title: 開発チームでの Slack 活用 -->

# 開発チームでの Slack 活用

「なんとなく使っている」から「チームの情報インフラになっている」状態にするための設計と Tips。

---

## チャンネル命名規則

命名規則がないと、チャンネルが増えるにつれて何がどこにあるかわからなくなる。プレフィックスで種類を分類するのが定番。

| プレフィックス | 用途 | 例 |
|---|---|---|
| `#dev-` | 開発全般 | `#dev-general`, `#dev-infra` |
| `#pj-` | プロジェクト単位 | `#pj-payment-renewal` |
| `#alert-` | 自動アラート専用 | `#alert-prod`, `#alert-staging` |
| `#inc-` | インシデント対応 | `#inc-20240315-db-down` |
| `#ext-` | 外部（クライアント・ベンダー） | `#ext-vendorname` |
| `#tmp-` | 一時的（終わったら archive） | `#tmp-migration-work` |

アラートチャンネルは**人間の会話を混ぜない**のが鉄則。通知が埋もれる原因になる。

---

## スレッドの使い方

チャンネルに直接返信するとタイムラインが荒れる。スレッドを使う場面を決めておく。

```
チャンネルに書くべきもの: 全員に見せたい新しい話題
スレッドで返すべきもの: そのトピックへの返答・深掘り
```

**スレッドをチャンネルにも通知する（Also send to #channel）** は原則使わない。全員への通知が必要なときはチャンネルに新規メッセージで書く。

---

## GitHub 連携

```
/github subscribe org/repo pulls reviews comments
```

Slack の GitHub アプリで PR・Issue・CI の通知をチャンネルに集約できる。`#alert-prod` ではなく `#dev-backend` のようなチームチャンネルに流すのがよい。

**Slack から直接できること:**
- `/github close #123` — Issue をクローズ
- `/github subscribe org/repo` — リポジトリを購読
- PR 通知から直接コメント・承認（モバイルでも）

---

## CI/CD の通知を Slack に流す

GitHub Actions から Slack に通知を送る。

```yaml
# .github/workflows/deploy.yml
- name: Notify Slack
  uses: slackapi/slack-github-action@v2
  with:
    channel-id: 'alert-prod'
    slack-message: |
      デプロイ完了 :rocket:
      Ref: ${{ github.ref }}
      By: ${{ github.actor }}
  env:
    SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
```

失敗時だけ通知したい場合は `if: failure()` を付ける。

---

## Incoming Webhook で任意のシステムから通知

モニタリングツール・自作スクリプト・AWS Lambda など何からでも Slack に送れる。

```python
import urllib.request
import json

def notify_slack(message: str, webhook_url: str):
    payload = {"text": message}
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        webhook_url,
        data=data,
        headers={"Content-Type": "application/json"}
    )
    urllib.request.urlopen(req)

notify_slack("バッチ処理完了: 3,412件処理", webhook_url=WEBHOOK_URL)
```

Slack アプリの管理画面から「Incoming Webhook」を有効化して URL を払い出す。

---

## Workflow Builder で定型通知を自動化

コードを書かずに自動化できる。よく使うパターン：

**定時リマインダー:**
月曜 10 時に `#dev-general` に「週次スプリントレビュー 13 時〜」を自動投稿する。

**フォーム → チャンネル投稿:**
「障害報告フォーム」を作り、入力内容が `#inc-*` チャンネルに自動投稿 → 担当者にメンションが飛ぶ。

**承認フロー:**
誰かが申請 → 承認者に DM → 「承認」「却下」ボタン → 結果をチャンネルに投稿。

---

## よく使うショートカット・コマンド

| 操作 | ショートカット |
|---|---|
| どこからでも検索 | `Cmd/Ctrl + K` |
| 未読を全部既読にする | `Esc` |
| スレッドに返信 | `T`（メッセージにカーソル） |
| 絵文字リアクション | `E`（メッセージにカーソル） |
| チャンネル切り替え | `Cmd/Ctrl + K` → チャンネル名 |
| DM を開く | `Cmd/Ctrl + Shift + K` |
| リマインダー設定 | メッセージを右クリック → 「後で通知」 |

```
/remind #dev-general 金曜 17:00 週報を書こう
/remind me tomorrow at 9am プルリクレビューする
```

---

## Slack Connect（外部との共有チャンネル）

ベンダー・クライアント・パートナーと Slack チャンネルを共有できる。メールでのやりとりをなくせる。

設定: チャンネル設定 → 「メンバーを追加」→ 外部メールアドレスを入力

注意点:
- 外部ユーザーがアクセスできる情報は共有チャンネルの会話のみ
- 社内の他チャンネルには見えない
- 共有中は `🔗` マークが付く

---

## PagerDuty / Datadog / AWS との連携

インシデント対応の流れを Slack 上で完結させる。

```
AWS CloudWatch アラーム発火
  → SNS → Lambda → Slack #alert-prod に投稿
  → PagerDuty が電話 on-call エンジニアに
  → エンジニアが Slack で「対応中」とリアクション
  → インシデントチャンネル #inc-yyyymmdd-xxx を作成
  → 対応完了 → ポストモーテムをスレッドに記録
```

Datadog の Slack インテグレーションは Monitor アラートを直接チャンネルに送れる。`/datadog` コマンドでダッシュボードのスナップショットを Slack に表示することも可能。
