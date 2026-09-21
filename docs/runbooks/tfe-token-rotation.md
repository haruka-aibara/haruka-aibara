# TFE_TOKEN 自動ローテーション

**この文書を読むとき:** 初回のブートストラップをやるとき。run が「トークンが無効」で落ちて文鎮化を疑うとき。周期を変えるとき。トークンが漏れて今すぐ回したいとき。

**3行:**

- workspace `works` が自分の次の `TFE_TOKEN` を発行する。人が触るのは**初回だけ**
- トークンは blue / green の 2 本を半周期ずらして持ち、run は**使っていない方**だけを作り直す
- **`TFE_TOKEN` という変数は消えない。** これが変えるのは権限の広さと露出期間であって、静的シークレットが無くなるわけではない（無くなるのは Vault を挟んだときだけ）

---

## 1. しくみ

```
周期が来る
  → time_rotating が作り直される（plan のたびにプロバイダが現在時刻と比較している）
  → 基準時刻が「今」に動く
  → そこから導出した失効時刻が変わる
  → その失効時刻を description に持つ team token が作り直される
  → TFE_TOKEN に新しい値が書き戻される
```

**定期ローテーションではコードが1文字も変わらない。** 差分は時計から出る。やることは Plan & Apply を1回通すだけで、PR は要らない。

差分が出たことを知らせる仕組みは無い。plan を走らせて初めて分かる。

### なぜ 2 本なのか

apply は**自分が認証に使っているトークンを消せない**。途中で消すと残りの API 呼び出しが 401 になり、変数の書き戻しに失敗して次の run も動けなくなる（＝文鎮化）。だから常に「使っていない方」だけを作り直す。

`tfe_team_token` には `create_before_destroy` を付けてあるので、両方が同時に作り直される変更（周期の変更など）でも、新トークンの発行と `TFE_TOKEN` の書き戻しが終わってから旧トークンが revoke される。保険であって、これに頼る運用はしない。

---

## 2. 値

| 変数 | 既定値 | 意味 |
|---|---|---|
| `rotation_minutes` | `230400`（160日） | 周期。**引き継ぎは半分の 80 日ごと** |
| `buffer_minutes` | `4320`（3日） | 引き継ぎ後にトークンが生き残る時間。**run を回し忘れても許される日数**でもある |

関係式はこれだけ覚えればいい。

```
引き継ぎ     = 周期 ÷ 2
トークン寿命 = 引き継ぎ + 猶予
```

既定値なら寿命は 83 日。**周期を変えれば寿命も自動で追従する**（定数を書いていないので引き直し忘れが起きない）。「認証情報は90日以内に失効させること」のような要件があるなら、許される寿命 L に対して `周期 ≤ (L − 猶予) × 2` で決める。

猶予が半周期以上になる値は validation で弾かれる（トークンが自分を置き換えるローテーションより長生きしてしまうため）。

---

## 3. 初回ブートストラップ

**前提:** いまの `TFE_TOKEN` は手で入れた user token で、これが最後の手作業になる。

### 3.1 既存変数の id を調べる

`tfe_variable` は key の重複を許さないので、UI で作った `TFE_TOKEN` を**作り直すのではなく取り込む**。そのために `var-...` の id が要る。

```bash
export TFE_TOKEN=<いま workspace に入っているのと同じ user token>

# workspace id
WS=$(curl -s -H "Authorization: Bearer $TFE_TOKEN" \
  https://app.terraform.io/api/v2/organizations/haruka-aibara/workspaces/works \
  | jq -r .data.id)

# TFE_TOKEN 変数の id
curl -s -H "Authorization: Bearer $TFE_TOKEN" \
  https://app.terraform.io/api/v2/workspaces/$WS/vars \
  | jq -r '.data[] | select(.attributes.key=="TFE_TOKEN") | .id'
```

### 3.2 workspace に変数を置く

`works` workspace の Variables に、**Terraform variable**（env ではない）として追加する。

| key | value | 備考 |
|---|---|---|
| `tfe_token_variable_id` | `var-xxxxxxxx` | 3.1 で調べた id |
| `rotation_minutes` | `60` | 検証する場合のみ。しない場合は置かない |
| `buffer_minutes` | `20` | 同上 |

### 3.3 マージする

`auto_apply = true` なので merge した時点で apply が走り、1回の apply で

1. team `works-manager` を作る
2. blue / green のトークンを発行する
3. 既存の `TFE_TOKEN` 変数を取り込み、**green のトークンで上書きする**

まで終わる。この apply 自身は、run 開始時に読み込まれた user token で最後まで動くので、途中で自分の認証を失うことはない。

### 3.4 `tfe_token_variable_id` を消す（必須）

**これを消し忘れると、次の run が「すでに Terraform が管理しているリソースを import しようとしている」で必ず失敗する。** apply が終わったら UI から削除する。

### 3.5 通ることを確認する

HCP で Actions → Start new run（Plan only）。これが通れば、**team token で動いている**ということ。落ちたら §6 へ。

### 3.6 半周期後にズラす

blue と green は同時に作られるので、放っておくと**同じ日に両方が作り直される**。そうなると使用中のトークンごと巻き込まれる。初回 apply から半周期後（既定値なら 80 日後、検証中なら 30 分後）に、**`blue_serial` を `2` に上げる PR を1本出す**。

同値のとき `timecmp` は green を選ぶので、**初回に使っていないのは blue のほう**。上げるのは必ず blue。

これで blue の基準時刻だけが半周期ずれ、以降は各色が自分の基準時刻から回るのでズレは自動で維持される。

### 3.7 旧 user token を revoke する

3.5 が通ったら、もう使われていない。HCP の User Settings → Tokens から消す。

---

## 4. 短周期で検証する

`rotation_minutes = 60` / `buffer_minutes = 20` を置いた場合のタイムライン。引き継ぎ 30 分、寿命 50 分、猶予 20 分。

| 時刻 | 起きること | やること |
|---|---|---|
| `t0` | 初回 apply。blue/green 発行、`TFE_TOKEN` = green | — |
| `t0+30` | — | **`blue_serial` を上げる PR を merge**。blue が作り直され `TFE_TOKEN` = blue に |
| `t0+50` | green が自動失効（引き継ぎの 20 分後） | — |
| `t0+60` | green の周期到来 | **Plan & Apply**。green が作り直され `TFE_TOKEN` = green に戻る |
| `t0+90` | blue の周期到来 | **Plan & Apply**。以降 30 分ごと |

見るべきものは3つ。

- **コードを変えていないのに plan に差分が出る**こと（`time_rotating` が remove + create として現れる）
- Organization Settings → API Tokens → Team Tokens で、トークンが 2 本あり、**片方だけが入れ替わる**こと
- 各トークンの Expires が、引き継ぎの 20 分後になっていること

**`t0+60` を過ぎても run を回さないと文鎮化する。** 猶予 20 分は「回し忘れても許される時間」そのもので、人が思い出して押す運用と組み合わせてはいけない値。検証が終わったら `rotation_minutes` / `buffer_minutes` を UI から削除して本番値に戻す（トークンは作り直されるが、`create_before_destroy` があるので安全）。

---

## 5. 予定外のローテーション（漏洩時）

周期を待たずに今すぐ回す。**使っていない側の serial を上げる PR** を出す。merge → apply で切替まで終わる。

使用中がどちらかは、Team Tokens の description（`works blue r1 exp ...` / `works green r1 exp ...`）のうち **Expires が遠いほう**が現役。

**使用中の側を上げてはいけない。** その apply が自分の認証を消す。使用中のトークンが漏れた場合の順序は「**先に切替、後に失効**」で、

1. 未使用側の serial を上げた PR を merge（切替が終わる）
2. そのあと漏れたトークンを UI か API で revoke

先に revoke すると、`TFE_TOKEN` が死んだトークンを指したまま次の run が動けなくなる。

---

## 6. 文鎮化からの復旧

症状は「run が HCP API の認証で落ちる」。原因は2つしかない。

**A. トークンが全部失効した**（run を長期間回していなかった）

初回と同じブートストラップをやり直す。§3.2 の `tfe_token_variable_id` は不要で、代わりに:

1. UI で `TFE_TOKEN` を自分の user token に差し替える
2. Plan & Apply を1回通す（失効したトークンが作り直され、`TFE_TOKEN` が上書きされる）
3. user token を revoke する

**B. team の権限が足りない**

`works-manager` に足りない権限がある。`tfe_token_rotation.tf` の `organization_access` に足して、A と同じ手順で復旧する。いま持っているのは3つ。

| 権限 | 何のため |
|---|---|
| `manage_workspaces` | workspace とその変数 |
| `manage_vcs_settings` | `data.tfe_oauth_client` と `vcs_repo` |
| `manage_teams` | **自分のチームとトークンを作り直すため**（ループの要） |

---

## 7. 前提と、消えないもの

**run が定期的に回っていること**がこの仕組みの前提。周期の半分（既定値なら 80 日）より短い間隔で run が走らないと、引き継ぎが起きないまま全トークンが失効する。この repo は VCS 連携で merge のたびに run が走るので自然に満たされるが、**80 日間 1 度も merge しなかったら壊れる**。検知すべき異常として扱う。

そして正直に書いておくと、これで**静的シークレットは 1 本も減らない**。

| | 前 | 後 |
|---|---|---|
| 権限 | owner 相当（全 workspace、全 state） | team の 3 権限 |
| 期限 | 実質無期限 | 83 日 |
| 紐づき | 個人アカウント | チーム |
| 更新 | 手動（やらなければ永久に同じ値） | 自動 |
| 置き場所 | workspace 変数 | workspace 変数 + **state** |

トークンが state に載るのは避けられない。この構成が発行する値だからで、`GITHUB_APP_*` のように「宣言だけ Terraform、値は UI」にはできない。

---

## 関連

- [GitHub 認証のしくみ](../reference/github-authentication.md) — なぜ VCS 連携が OAuth なのか（team token でローテするための前提）
- `tfe_token_rotation.tf` — 実装
