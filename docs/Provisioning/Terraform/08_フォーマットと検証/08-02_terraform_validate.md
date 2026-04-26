<!-- Space: harukaaibarapublic -->
<!-- Parent: 08_フォーマットと検証 -->
<!-- Title: terraform validate -->

# terraform validate

「plan を実行したら存在しないリソース名を参照してエラーになった」—plan は AWS に API を叩くのでそれなりに時間がかかる。`validate` は API 呼び出しなしで構文・論理チェックができるので、plan の前に素早くエラーを潰せる。

---

## 基本的な使い方

```bash
# 事前に init が必要
terraform init
terraform validate
```

問題がなければ：
```
Success! The configuration is valid.
```

エラーがあれば：
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

- HCL の構文エラー
- 未定義の変数・リソースへの参照
- 必須属性の欠落
- 型の不一致

---

## validate vs plan

| | validate | plan |
|---|---|---|
| AWS API 呼び出し | なし | あり |
| 認証情報 | 不要 | 必要 |
| 速度 | 速い | 遅い |
| チェック精度 | 構文・論理のみ | 実際のリソース状態も確認 |

CI での順番: `fmt -check` → `validate` → `plan`
validate はオフラインで動くので、認証情報を使わない静的チェックのステージでも実行できる。
