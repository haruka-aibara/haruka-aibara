<!-- Space: harukaaibarapublic -->
<!-- Parent: 08_フォーマットと検証 -->
<!-- Title: terraform validate -->

# terraform validate

Terraform 設定の構文・論理的な正しさをチェックするコマンド。実際の API 呼び出しは行わない。

---

## 基本的な使い方

```bash
# 事前に terraform init が必要
terraform init
terraform validate
```

正常な場合：
```
Success! The configuration is valid.
```

エラーがある場合：
```
╷
│ Error: Reference to undeclared resource
│
│   on main.tf line 10, in resource "aws_subnet" "app":
│   10:   vpc_id = aws_vpc.nonexistent.id
│
│ A managed resource "aws_vpc" "nonexistent" has not been declared...
╵
```

---

## チェックされる内容

- 構文エラー（HCL の文法）
- 未定義の変数・リソースへの参照
- 必須属性の欠落
- 型の不一致

---

## CI/CD での活用

```yaml
- name: Validate
  run: terraform validate
```

`fmt` → `validate` → `plan` の順でチェックすることで、PR マージ前に問題を検出できる。

---

## terraform validate vs terraform plan

| | validate | plan |
|---|---|---|
| API 呼び出し | なし | あり（Read API） |
| 認証情報 | 不要 | 必要 |
| チェック精度 | 構文・論理 | 構文・論理 + 実際のリソース状態 |

`validate` はオフラインで実行できるため、認証なしのステージでも動かせる。
