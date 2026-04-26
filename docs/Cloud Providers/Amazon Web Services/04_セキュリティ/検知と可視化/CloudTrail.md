<!-- Space: harukaaibarapublic -->
<!-- Parent: 検知と可視化 -->
<!-- Title: CloudTrail -->

# CloudTrail

「誰かがセキュリティグループを変更した」「IAM ポリシーが書き換えられた」——こういうことが起きたとき、CloudTrail がなければ誰がいつ何をしたか追跡できない。CloudTrail は AWS アカウント内の API 操作をすべて記録するサービス。有効化しておかないとインシデント発生時に証拠が残らない。

---

## CloudTrail が記録するもの

- **誰が**：IAM ユーザー / ロール / root / AWS サービス
- **何を**：API コール（EC2 インスタンスの起動、S3 バケットの削除、IAM の変更 など）
- **いつ**：タイムスタンプ
- **どこから**：ソース IP アドレス / User-Agent
- **成功したか**：エラーコード

---

## 有効化と設定

デフォルトで「イベント履歴」として 90 日分のログが保存されるが、S3 への証跡（Trail）を別途作成しないと長期保存できない。

```bash
# Trail を作成して S3 に保存
aws cloudtrail create-trail \
  --name my-trail \
  --s3-bucket-name my-cloudtrail-bucket \
  --is-multi-region-trail \
  --enable-log-file-validation

# ログ記録を開始
aws cloudtrail start-logging --name my-trail
```

`--is-multi-region-trail` をつけないと、Trail を作成したリージョンのログしか取得できない。

---

## ログファイル検証

ログが改ざんされていないか確認できる。

```bash
aws cloudtrail validate-logs \
  --trail-arn arn:aws:cloudtrail:ap-northeast-1:123456789012:trail/my-trail \
  --start-time 2024-01-01T00:00:00Z
```

---

## CloudWatch Logs との連携

CloudTrail ログを CloudWatch Logs に流すと、メトリクスフィルタとアラームで特定の操作を即座に検知できる。

```bash
# CloudTrail → CloudWatch Logs を設定
aws cloudtrail update-trail \
  --name my-trail \
  --cloud-watch-logs-log-group-arn arn:aws:logs:ap-northeast-1:123456789012:log-group:CloudTrail
```

検知したい操作の例：

| 監視対象 | メトリクスフィルタのパターン |
|---|---|
| root ユーザーのログイン | `{ $.userIdentity.type = "Root" }` |
| MFA なしの Console ログイン | `{ $.eventName = "ConsoleLogin" && $.additionalEventData.MFAUsed = "No" }` |
| セキュリティグループの変更 | `{ $.eventName = "AuthorizeSecurityGroupIngress" }` |
| CloudTrail の停止 | `{ $.eventName = "StopLogging" }` |

---

## 注意点

- S3 バケットへのパブリックアクセスを必ず無効化する
- S3 バケット自体のオブジェクト操作ログは CloudTrail ではなく S3 Server Access Logging または CloudTrail データイベントで別途取得が必要
- 組織全体のログは Organizations Trail で一元収集できる
