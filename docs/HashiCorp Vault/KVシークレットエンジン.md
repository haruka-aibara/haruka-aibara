# KV シークレットエンジン

## 問題

「DB のパスワードを安全に保管して、必要なときだけ取り出せるようにしたい」というのが一番シンプルな Vault の使い方。KV（Key-Value）シークレットエンジンがこれを担う。

---

## KV v1 と v2 の違い

| | KV v1 | KV v2 |
|--|-------|-------|
| バージョン管理 | なし | あり（デフォルト10世代） |
| 削除の取り消し | 不可 | 可（soft delete） |
| チェックアンドセット | なし | あり（競合防止） |

新しく使うなら **KV v2 一択**。HCP Vault はデフォルトで KV v2 が有効になっている。

---

## 基本操作

### UI から操作する場合

HCP Vault の画面から Secrets → KV エンジンを選択 → 「Create secret」でパスを指定して値を入れるだけ。

### CLI から操作する場合

```bash
# Vault にログイン
vault login

# シークレットを書く
vault kv put secret/myapp/database \
  password="s3cr3t" \
  username="appuser"

# シークレットを読む
vault kv get secret/myapp/database

# 特定のフィールドだけ取り出す
vault kv get -field=password secret/myapp/database

# バージョン一覧
vault kv metadata get secret/myapp/database

# 1世代前のバージョンを読む
vault kv get -version=1 secret/myapp/database
```

### API から操作する場合（スクリプトや CI から使う場合）

```bash
# トークンで認証してシークレットを取得
curl -H "X-Vault-Token: $VAULT_TOKEN" \
  "$VAULT_ADDR/v1/secret/data/myapp/database"
```

レスポンスの `data.data` に値が入っている。

---

## パスの設計

シークレットのパスは自由に設計できる。チームやアプリ・環境で階層を切るのが一般的。

```
secret/
├── platform/
│   ├── github-token
│   └── slack-webhook
├── myapp/
│   ├── dev/
│   │   └── database
│   └── prod/
│       └── database
└── shared/
    └── datadog-api-key
```

パスがそのままポリシーの適用単位になるので、最初に設計しておくと後が楽。

---

## 誰が読めるかはポリシーで制御する

```hcl
# myapp の dev 環境だけ読めるポリシー
path "secret/data/myapp/dev/*" {
  capabilities = ["read"]
}

# myapp の全環境を管理できるポリシー
path "secret/data/myapp/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

このポリシーをトークンやロールに紐づける。誰がどのパスにアクセスできるかが明示的になり、監査ログと合わせて「誰がいつ何を読んだか」を追跡できる。
