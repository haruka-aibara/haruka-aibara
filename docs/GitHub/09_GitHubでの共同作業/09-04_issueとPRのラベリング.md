# issue と PR のラベリング

issue が100件を超えたあたりで、「どれがバグでどれが要望か」「今スプリントでやるのはどれか」が誰にも分からなくなる。ラベルは issue/PR につける色付きタグで、**一覧を「検索・絞り込みできるデータベース」に変える**ための仕組み。

## 基本操作

issue/PR の右サイドバー「Labels」から付与する。リポジトリには `bug` `enhancement` `documentation` `good first issue` などのデフォルトラベルが最初から用意されており、Settings → Labels で追加・編集できる。

真価は絞り込みで出る。issue 一覧の検索窓でこう書ける：

```
is:open label:bug label:priority-high     # 優先度高のバグだけ
is:pr is:open -label:wip                  # WIP を除いたオープン PR
is:open no:label                          # ラベル未整理のもの（トリアージ対象）
```

## 運用設計：ラベルは「軸」で揃える

ラベルが乱立して機能しなくなるのは、軸の違うものが混ざるから。実務では**接頭辞で軸を明示**するのが定石：

- **type/**: `type/bug`, `type/feature`, `type/docs` — 何の種類か
- **priority/**: `priority/high`, `priority/low` — いつやるか
- **status/**: `status/blocked`, `status/needs-review` — 今どういう状態か
- **area/**: `area/auth`, `area/infra` — どこの話か

「1つの issue に各軸から最大1つ」と決めておくと、`label:type/bug label:priority/high` のような掛け算の絞り込みが安定して機能する。ラベルの意味は README や CONTRIBUTING に書いておかないと、人によって解釈が割れて崩壊する（`wontfix` を付ける基準、など）。

## 自動化と組み合わせて本領発揮

ラベルは人が見るだけでなく、**自動化のトリガー・条件**として使える：

- **labeler Action**：変更ファイルのパスに応じて PR に `area/` ラベルを自動付与
- **release-drafter / Release Notes 自動生成**：`type/feature` と `type/bug` を分類してリリースノートの節を自動で分ける
- **stale Action**：一定期間動きのない issue に `stale` を付けて通知→クローズ
- OSS では `good first issue` が新規貢献者の入口として機能する（GitHub がこのラベルを特別扱いして紹介ページに載せる）

「人間の分類作業」を入口の一回だけにして、あとは自動化が消費する——ここまで設計して初めてラベルは回り続ける。

## 参考

- [Managing labels — GitHub Docs](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels)
- [actions/labeler — GitHub](https://github.com/actions/labeler)
