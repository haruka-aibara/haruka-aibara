# Renovate の Dependency Dashboard

## どういうときに必要になるか

Renovate を導入すると、こんな場面に遭遇する。

- **PR が大量に来てレビューが追いつかない**。全部マージするまで次々と PR が作られ、PR 一覧が Renovate で埋まる
- **「今どの更新が保留されているのか」が分からない**。レート制限（`prConcurrentLimit` など）やスケジュール設定で抑制されている更新は、PR が存在しないので気づけない
- **一度クローズした Renovate の PR を、後からやっぱり適用したくなった**。Renovate はクローズされた更新を「却下された」とみなして同じ PR を作り直さないので、復活させる手段が必要

これらをまとめて解決するのが Dependency Dashboard。リポジトリに Issue が 1 つ作られ、**保留中・オープン・クローズ済み・エラーのすべての更新が一覧表示され、チェックボックスで操作できる**ようになる。

## 何ができるか

ダッシュボード Issue のチェックボックスにチェックを入れると、Renovate が次回実行時にそれを読み取って動く。

- **承認待ちの更新の PR 作成をトリガーする**（後述の `dependencyDashboardApproval` と組み合わせる）
- **レート制限やスケジュールで抑制されている PR を強制的に作らせる**。「今すぐこの更新が欲しい」ときに設定をいじらずに済む
- **オープン中の PR を rebase / retry する**。コンフリクトした PR の作り直しをダッシュボードからまとめて指示できる
- **クローズ済みの更新の PR を再作成する**。却下した更新を復活させたいときはここ

ほかに、レジストリ上で非推奨（deprecated）になったパッケージの警告も表示されるので、「動いてはいるがもうメンテされていない依存」に気づける。

## 有効化

v26 以降の `config:recommended` を継承していればデフォルトで有効。明示的に有効化するなら：

```json
{
  "extends": ["config:recommended", ":dependencyDashboard"]
}
```

無効化したい場合は `:disableDependencyDashboard` を extends に入れるか、`"dependencyDashboard": false` を指定する。

**前提条件**：プラットフォームに Issue 機能（チェックボックス付き Markdown が動く Issue）が必要。GitHub でリポジトリの Issues を無効にしているとダッシュボードは作られない。

## 場面別の使い方

### PR が多すぎる → ダッシュボード承認制にする

`dependencyDashboardApproval` を有効にすると、Renovate はいきなり PR を作らず、ダッシュボードに「承認待ち」として更新を並べる。チェックを入れた更新だけ PR が作られる。

全部を承認制にするのは公式も推奨していない（更新が滞るだけになりがち）。**メジャーアップデートだけ承認制**にするのが現実的：

```json
{
  "extends": ["config:recommended"],
  "major": {
    "dependencyDashboardApproval": true
  }
}
```

特定のパッケージ群だけ承認制にすることもできる。たとえば AWS Provider のように影響範囲が大きいものだけ手動ゲートを置く：

```json
{
  "packageRules": [
    {
      "matchPackageNames": ["hashicorp/aws"],
      "dependencyDashboardApproval": true
    }
  ]
}
```

なお、脆弱性対応の PR（vulnerability alerts 起点）は承認待ちをスキップして作られる。セキュリティパッチが承認制で止まる心配はない。

### 抑制されている更新を今すぐ取り込みたい

`prConcurrentLimit` で同時 PR 数を絞っていたり、`schedule` で週末のみ実行にしていると、「更新があるのに PR が来ない」状態が生まれる。ダッシュボードには Pending として表示されるので、急ぎのものだけチェックを入れて PR を作らせる。設定を一時的に書き換える必要がない。

### 却下した更新を復活させたい

クローズした PR の更新は Closed セクションに残っている。チェックを入れれば PR が再作成される。「このメジャーアップデートは今は見送り、半年後にやる」という運用がダッシュボード上で完結する。

## セキュリティ視点：脆弱性サマリーを出す

`dependencyDashboardOSVVulnerabilitySummary` を設定すると、OSV データベース由来の CVE 一覧をダッシュボードに表示できる（デフォルトは `none`）。

```json
{
  "dependencyDashboardOSVVulnerabilitySummary": "unresolved"
}
```

`unresolved`（修正版が出ていない CVE のみ）か `all` を選べる。「依存関係にどんな既知脆弱性が残っているか」を Issue 1 つで定点観測できるので、脆弱性管理ツールを別途入れるほどではない小規模リポジトリで有用。

## その他のオプション

| オプション | 用途 |
|---|---|
| `dependencyDashboardTitle` | Issue タイトルの変更（デフォルトは "Dependency Dashboard"） |
| `dependencyDashboardLabels` | Issue にラベルを付与 |
| `dependencyDashboardAutoclose` | 保留中の更新がなくなったら Issue を自動クローズ（デフォルト false） |
| `dependencyDashboardHeader` / `dependencyDashboardFooter` | Issue 本文の先頭・末尾に独自テキストを追加 |

## 参考

- [Renovate Docs - Dependency Dashboard](https://docs.renovatebot.com/key-concepts/dashboard/)
- [Renovate Docs - Configuration Options: dependencyDashboard](https://docs.renovatebot.com/configuration-options/#dependencydashboard)
- [Renovate Docs - Configuration Options: dependencyDashboardApproval](https://docs.renovatebot.com/configuration-options/#dependencydashboardapproval)
