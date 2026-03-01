<!-- Space: harukaaibarapublic -->
<!-- Parent: 13_Stateの検査と修正 -->
<!-- Title: terraform state pull / push -->

# terraform state pull / push

State ファイルをローカルに取得・アップロードするコマンド。

---

## terraform state pull

リモートバックエンドから現在の State を取得してローカルに出力する。

```bash
# バックアップとして保存
terraform state pull > backup-$(date +%Y%m%d).tfstate

# JSON として整形して閲覧
terraform state pull | jq '.resources[] | {type: .type, name: .name}'
```

---

## terraform state push

ローカルの State ファイルをリモートバックエンドにアップロードする。

```bash
terraform state push backup.tfstate
```

---

## 使いどころ

**State の手動修正（慎重に）**

```bash
# 1. バックアップ
terraform state pull > backup.tfstate

# 2. ローカルで編集（基本的には state rm / mv を使う方が安全）
cp backup.tfstate modified.tfstate
# ... 編集 ...

# 3. アップロード
terraform state push modified.tfstate
```

**State のバックエンド移行**

```bash
# 旧バックエンドから取得
terraform state pull > state.tfstate

# バックエンド設定を変更して init
terraform init -migrate-state
```

---

## 注意

- `push` は現在の State を上書きする。誤った State を push するとインフラ管理が壊れる
- 必ずバックアップを取ってから操作する
- チームで使う場合はロックを確認する（`push` は State ロックをバイパスできる場合がある）
