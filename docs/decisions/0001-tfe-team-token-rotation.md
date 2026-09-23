# ADR-0001: TFE_TOKEN は workspace 自身が blue / green の team token で回す

## ステータス

採用 (2026-09-22)

## コンテキスト

workspace `works` の tfe provider は workspace 変数 `TFE_TOKEN` で認証している。元は手で入れた user token で、個人に紐づき、期限が無く、誰かが手で替えない限り同じ値が使われ続ける。

tfe provider では team token を発行できる。発行したトークンを `TFE_TOKEN` に書き戻せば、workspace が自分の次の認証情報を用意できる。ただし次の制約がある。

- apply は、自分が認証に使っているトークンを revoke できない。revoke すると残りの API 呼び出しが 401 で落ち、書き戻しも失敗して次の run が動かなくなる（文鎮化）。
- Free organization では team を作れない（`missing entitlements to create teams`）。専用 team で権限を絞る手は使えない。
- 定期実行の仕組みは持たない。run が起きるのは merge か手動の Plan & Apply のときだけ。

## 決定

`modules/tfe-team-token-rotation/` に次の仕組みを置き、ルートの `main.tf` から `module "tfe_team_token_rotation"` として呼ぶ。

- **トークンは2本（blue / green）を半周期ずらして持つ。** run が作り直すのは、認証に使っていない側だけにする。現役は基準時刻が新しいほうとし、それを `TFE_TOKEN` に書き戻す。
- **時計は `time_rotating`、差分は時計から出す。** 定期ローテーションではコードを変えない。周期が過ぎた後の最初の plan で時計が作り直され、それに連動してトークンが作り直される。`rfc3339` は固定しない。固定すると基準時刻が動かず、トークンが回らなくなる。
- **寿命は周期から導出する。** 寿命 = 周期 ÷ 2 + 猶予。定数にすると、周期を変えたときに寿命が追従しない。猶予は半周期より短くなるよう validation で強制する。
- **失効時刻を description に入れる。** team token は description で識別されるので、失効時刻が変わればトークンの作り直しになり、新旧2世代が同時に存在できる。token 一覧で失効時刻も見える。
- **`create_before_destroy` を保険として付ける。** 両色が同時に作り直される変更（周期の変更など）でも、書き戻しが終わってから旧トークンが revoke される。これに頼る運用はしない。
- **発行元は owners team にする。** Free で使える唯一の選択肢。有料エディションに上げたら専用 team に向け直す。
- **予定外のローテーションは serial で行う。** `blue_serial` / `green_serial` を `time_rotating` の `triggers` に入れ、上げた色の時計を「今」に張り直す。値はモジュール引数として `main.tf` に置き、上げる PR が1行で済むようにする。
- **周期と猶予はルートにも変数として残す。** 短周期の検証では UI から Terraform 変数で上書きするため。ルート側は `default = null`、モジュール側は `nullable = false` にして、未設定のときはモジュールの既定値に落とす。既定値と validation はモジュール側の1か所だけに書く。
- **モジュール化するときは `moved` でアドレスを引き継ぐ。** 作り直しが起きると使用中のトークンまで巻き込まれるため。`tfe_variable.tfe_token` の description は旧ファイル名のまま据え置く。書き換えると、コメントのためだけに実変数の in-place update が走る。

## 検討した代替案

- **トークン1本を回す:** 作り直す apply の中で、自分の認証を消すことになる。
- **organization token:** organization に有効な token は1本だけで、再生成すると既存の token が置き換わる。2本持てないので、1本を回す場合と同じ問題が起きる。
- **外部スケジューラ（GitHub Actions の cron など）で API から回す:** 発行した値を別のシークレットとして持ち込むことになり、管理対象が増える。Terraform の外で `TFE_TOKEN` を書き換えると、state との整合も崩れる。

## トレードオフ

- **権限は縮まない。** owners team の token は owner 相当の権限を持つ。得られるのは、期限が付くこと、人に紐づかないこと、自動で入れ替わることの3点だけ。
- **トークンが state に載る。** この構成が発行する値なので避けられない。
- **run が定期的に回ることが前提。** 半周期 + 猶予（既定値なら 83 日）の間に run が1度も無いと、全トークンが失効する。差分が出たことを知らせる仕組みも無い。
- **初回のブートストラップと、半周期後のずらし（blue の serial を上げる）は手作業。**

手順は [TFE_TOKEN 自動ローテーション](../runbooks/tfe-token-rotation.md) を参照。
