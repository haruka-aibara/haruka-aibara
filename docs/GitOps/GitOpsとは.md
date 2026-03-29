# GitOps とは

## こういう場面で困っていないか

Kubernetes クラスターに変更を加えたとき、「誰が、いつ、何を変えたか」を追えるか？

- `kubectl apply` をローカルから直接叩いた
- CI が終わったあと、手順書に従ってダッシュボードをポチポチ操作した
- 本番に何が入っているかは、クラスターに聞かないとわからない

こういう運用を続けると、障害のとき「なぜこうなったのか」が誰にもわからない状態になる。GitOps はその問題に対するアプローチだ。

---

## GitOps の考え方

**Git リポジトリを「あるべき状態の唯一の情報源（Single Source of Truth）」にする**、という運用モデル。

- インフラやアプリの望ましい状態を Git に宣言的に書く
- Git への変更（PR → マージ）が唯一の変更手段になる
- ツールが Git の状態とクラスターの実態を常に比較して、ズレを検知・自動修正する

直接 `kubectl apply` は原則禁止。変えたければ Git に PR を出す。

---

## 何が嬉しいのか

| 課題 | GitOps での対応 |
|---|---|
| 誰がいつ変えたかわからない | Git のコミット履歴がそのまま変更記録になる |
| 本番に何が入っているかわからない | Git の main ブランチが「現在の状態」を表す |
| 手動操作ミスで環境が壊れる | ツールが Git の状態に自動で戻す（自動修復） |
| 環境を作り直したい | Git リポジトリを apply するだけで再現できる |

特に複数人・複数クラスターを扱う場面で効いてくる。

---

## Push 型 vs Pull 型

GitOps の文脈で必ず出てくる区別。

**Push 型（従来の CI/CD）**
CI パイプラインが変更を検知して `kubectl apply` を外部から叩く。CI が直接クラスターに権限を持つ必要がある。

**Pull 型（GitOps 的アプローチ）**
クラスター内に常駐するエージェントが Git を監視して、自分で変更を取り込む。外部から直接クラスターを操作する必要がない。

```
[開発者] → PR → [Git リポジトリ]
                        ↑ 監視
               [クラスター内エージェント]
                        ↓ 同期
                 [Kubernetes クラスター]
```

Pull 型のほうがクレデンシャルの露出が少なく、クラスター外の CI にクラスターへの権限を与えなくてよい。

---

## Kubernetes 以外でも使えるか

GitOps の原則（Git を SSoT にする、Pull 型で同期する）は概念としては Kubernetes 専用ではない。Terraform や Ansible に対しても「Git の状態をインフラに適用する」という考え方は成立する。

ただし実態は Kubernetes の文脈で語られることがほぼすべて。主要ツールの Argo CD・Flux は Kubernetes 前提で設計されており、事例・コミュニティ・ドキュメントも圧倒的に Kubernetes が中心だ。

「GitOps = Kubernetes の話」と理解していて実務的には困らない。

---

## Terraform での GitOps はどうなるか

「Terraform コードを Git 管理して HCP Terraform と VCS 連携する」は、GitOps の精神をほぼ満たしている。

- Git が SSoT になる
- 変更は PR 経由
- マージしたら自動で apply
- 変更履歴が Git に残る

厳密には HCP Terraform の VCS 連携は Git の push イベントで webhook が発火する Push 型で、Argo CD のような「エージェントが常時 Git を監視する」Pull 型とは異なる。ドリフト（Git と実態のズレ）も自動修正はしない。

ただこの違いが問題になるかというと、Terraform の用途では「勝手に自動修正されると困る」ケースも多く、HCP Terraform の挙動のほうが実務に合っていることすらある。

わざわざ「GitOps」と呼ばれないのは、Kubernetes コミュニティが先にその言葉を使い倒したから、という側面が大きい。

---

## Argo CD は何者か

一言で言うと「Kubernetes 版の HCP Terraform」に近いイメージが掴みやすい。

| | HCP Terraform | Argo CD |
|---|---|---|
| 対象 | Terraform コード | Kubernetes マニフェスト |
| やること | Git の状態を AWS/GCP 等に apply | Git の状態をクラスターに sync |
| ドリフト検知 | plan で差分表示 | 常時監視して UI で可視化 |
| 自動修正 | 基本しない（手動 apply） | 設定次第で自動 sync |

「Git に書いてある状態をインフラに適用・維持するツール」という役割はほぼ同じ。

大きく違うのは、Argo CD はクラスター**内に**常駐するエージェントとして動く点。外部ツールがクラスターに触る必要がなく、クラスター自身が Git を見に行く構造になっている。

---

## 代表的なツール

- **Argo CD**: UI が充実。視覚的にクラスターの同期状態を確認できる。採用事例が多い
- **Flux**: CLI 中心。Helm・Kustomize との統合が柔軟。CNCF graduated

どちらも Pull 型の GitOps エージェント。「どちらが正解」というより、チームの好みと既存スタックに合わせて選ぶ。

---

## まず何をやるか

GitOps を始めるには「インフラをコードで表現する」が前提になる。

1. Kubernetes マニフェストを Git で管理する（`kubectl apply` のファイルをコミットする）
2. Helm chart または Kustomize で環境差分を管理する
3. Argo CD か Flux を入れて、Git とクラスターの同期を自動化する

「とりあえず Git に置く」だけでも、変更履歴の可視化という意味では効果がある。

---

## 参考

- [OpenGitOps - GitOps Principles](https://opengitops.dev/)
- [Argo CD 公式ドキュメント](https://argo-cd.readthedocs.io/en/stable/)
- [Flux 公式ドキュメント](https://fluxcd.io/flux/)
- [CNCF GitOps Working Group](https://github.com/cncf/tag-app-delivery/tree/main/gitops-wg)
