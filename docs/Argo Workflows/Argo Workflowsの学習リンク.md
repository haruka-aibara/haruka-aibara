# Argo Workflows の学習リンク

Argo Workflows を1時間以内で触ってみるための外部教材をメモしておく。自前でハンズオンを書かず、公式の教材を使う。

同じ Argo でも Argo CD は「Git の状態をクラスターに同期し続ける」もの（[Argo CDとは](../Argo%20CD/Argo%20CDとは.md)）で、Argo Workflows は「ステップの順番・並列・リトライを宣言して、処理を Pod として1回走らせる」もの。

## リンク

- **Killercoda の Argo シナリオ**
  https://killercoda.com/argoproj

  ブラウザ上に用意された Kubernetes 環境で進める。kind や CLI のセットアップが要らない。まず触るならこちら。

- **公式 Walk Through**
  https://argo-workflows.readthedocs.io/en/latest/walk-through/

  パラメータ・steps・DAG・artifact・リトライ・条件分岐などを例つきで順に扱う。手元のクラスターで試すとき、書き方を確認するときに開く。インストールは [Quick Start](https://argo-workflows.readthedocs.io/en/latest/quick-start/) を見る。

## どちらを開くか

| 場面 | 開くもの |
|---|---|
| 環境構築なしで、まず動くところを見たい | Killercoda |
| 手元のクラスターで試したい・書き方を調べたい | 公式 Walk Through |

## 参考

- Argo Workflows - Killercoda
  https://killercoda.com/argoproj
- Walk Through - Argo Workflows
  https://argo-workflows.readthedocs.io/en/latest/walk-through/
- Quick Start - Argo Workflows
  https://argo-workflows.readthedocs.io/en/latest/quick-start/
