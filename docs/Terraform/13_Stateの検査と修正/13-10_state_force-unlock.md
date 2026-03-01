<!-- Space: harukaaibarapublic -->
<!-- Parent: 13_Stateの検査と修正 -->
<!-- Title: terraform force-unlock -->

# terraform force-unlock

State のロックを強制的に解除するコマンド。プロセスが異常終了してロックが残った場合に使う。

---

## 基本的な使い方

```bash
terraform force-unlock LOCK_ID
```

`LOCK_ID` はロックエラーメッセージに表示される。

```
Error: Error acquiring the state lock

Lock Info:
  ID:        3f1a2b3c-4d5e-6f7a-8b9c-0d1e2f3a4b5c  ← これが LOCK_ID
  Path:      my-bucket/prod/terraform.tfstate
  Operation: apply
  Who:       alice@example.com
  Version:   1.9.0
  Created:   2024-01-15 10:30:00 +0000 UTC
```

---

## 実行

```bash
terraform force-unlock 3f1a2b3c-4d5e-6f7a-8b9c-0d1e2f3a4b5c
```

確認プロンプトが表示されるので `yes` を入力する。

---

## 注意

**本当にプロセスが終了していることを確認してから実行する。**

apply が途中で止まっているまま force-unlock すると、別のプロセスが同時に apply を実行できるようになり、State が競合して壊れる可能性がある。

確認の手順：
1. ロック情報の `Who` と `Created` を確認
2. 該当のユーザー・CI/CD パイプラインにプロセスが残っていないか確認
3. 残っていないことを確認してから実行

---

## DynamoDB でのロック確認

S3 + DynamoDB バックエンドの場合、DynamoDB テーブルでロックの状態を直接確認できる。

```bash
aws dynamodb scan --table-name terraform-lock
```
