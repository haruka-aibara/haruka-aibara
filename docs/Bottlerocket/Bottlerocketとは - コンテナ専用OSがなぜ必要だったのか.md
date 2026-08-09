# Bottlerocket とは - コンテナ専用 OS がなぜ必要だったのか

EKS や ECS のワーカーノードに Amazon Linux 2 / 2023 をそのまま使っているケースは多い。動くし、慣れているし、それで十分に見える。では Bottlerocket は何が違うのか、いつ選ぶべきなのか。

## 何が問題だったのか

汎用 Linux でコンテナを動かすとき、ホスト OS にはコンテナを実行するのに不要なものが大量に乗っている。

- パッケージマネージャ（yum / apt）
- SSH デーモン・各種ユーザー管理
- 任意のスクリプト言語ランタイム
- 設定ファイルが各ディレクトリに散らばっている
- カーネル・ライブラリのバージョンが個別に更新される

問題は2つ。

**攻撃面が広い**。コンテナで侵害された攻撃者がホストに脱出できた場合、汎用 Linux にはツールも設定変更の自由度もある。SSH 鍵を仕込む、cron を書く、パッケージを入れる、どれもやりやすい。

**運用が不揃いになる**。ノードごとに `yum update` のタイミングがズレ、設定ファイルが手で書き換えられ、長期間動かしているうちに "snowflake" になっていく。コンテナはイミュータブルに作っているのに、ホストはミュータブルというねじれが残る。

Bottlerocket はこのねじれを解消するために AWS が作った「コンテナを動かすこと **だけ** に特化した OS」。

## Bottlerocket の構造

普通の Linux と一番違うのはここ。

**ルートファイルシステムが読み取り専用**。`/` には書き込めない。dm-verity でハッシュ検証されているので、改ざんもできない。

**パッケージマネージャがない**。ソフトウェアを後から追加する仕組みそのものがない。必要なものは全部 OS イメージに焼かれている。逆に言えば、ホスト上で動くものは AWS が決めた最小限のセットだけ。

**SSH もシェルもデフォルトでは入っていない**。トラブル対応が必要なときは、専用の "admin container" を起動して中に入る。admin container は使い終わったら停止する前提で、これを常用するのは推奨されない。

**設定は API 経由**。`/etc/` を直接いじるのではなく、`apiclient` というツールで OS の設定を変える。設定はノード再起動でも維持される TOML 形式で管理される。

**更新は A/B パーティション方式**。新バージョンは別パーティションに書き込み、再起動で切り替える。失敗したら自動で元のパーティションに戻る（rollback）。スマホの OS アップデートに近い。

## どんなときに採用を検討するか

**向いている**:
- EKS / ECS のワーカーノード（公式サポートあり）
- マルチテナント環境でホストの分離レベルを上げたい
- ホストを「ペット」ではなく「家畜」として扱いたい
- コンプライアンス要件で OS の改ざん検知や更新トレーサビリティが求められる

**向いていない / 検討の余地あり**:
- ノードに直接ログインしてデバッグする運用が日常的
- ホスト上でデーモンやエージェントを動かす必要がある（一部のセキュリティエージェントは Bottlerocket に対応していない）
- カーネルモジュールを自作で入れたい
- 学習・検証用途で「使い慣れた Linux で十分」なケース

「コンテナだけ動けば良い」がはっきりしているなら筋がいい。一方、ホストに何かを足したくなる運用が残っているなら、まずそこを整理してからの方がハマりが少ない。

## セキュリティ視点で何が嬉しいか

セキュリティエンジニア視点だと、Bottlerocket の導入で得られる現実的な効果はこれ。

| やりたいこと | 汎用 Linux | Bottlerocket |
|---|---|---|
| ホストへのコンテナ脱出後の被害最小化 | カーネル・ツール群が攻撃に使える | ツール自体がない |
| OS の改ざん検知 | AIDE などを別途入れる | dm-verity で起動時検証 |
| 全ノードの構成統一 | Ansible 等で頑張る | OS の前提として揃う |
| OS 更新の追跡 | yum log を読む | A/B 切り替えで明確 |
| SSH 経由の不正アクセス | sshd を堅牢化 | そもそも sshd がない |

**ビジネス側への言語化**: 「ホスト OS にツールを入れない代わりに、コンテナ専用設計にした分だけ攻撃される表面積が物理的に小さい」「OS のバージョン管理がノード単位ではなくクラスタ単位で揃うので、脆弱性対応のばらつきがなくなる」あたりが刺さりやすい。

## 運用で詰まりやすいポイント

- **デバッグの作法が変わる**。`ssh` してログを見る発想は捨てる。admin container か SSM Session Manager 経由で入る
- **既存のホストエージェント（EDR・監視）が動かない場合がある**。導入前に対応状況を確認すること
- **カーネルモジュール拡張は基本ナシ**。eBPF ベースのツールは動くが、カーネルモジュールを差し込むタイプのものは対応していない
- **ログ収集の経路を決めておく**。Fluent Bit や CloudWatch Logs Agent をコンテナとして動かす構成にする

## 関連サービスとの位置づけ

- **EKS** — Bottlerocket は公式サポートされた AMI として利用可能（Managed Node Group でも選択できる）
- **ECS** — 同じく公式サポート AMI として提供
- **Karpenter** — Bottlerocket AMI を指定してスケーリングできる
- **Amazon Linux 2 / 2023** — 汎用 Linux。学習・移行コストは低いが、ホスト OS のメンテ責務は残る

## 参考

- [Bottlerocket 公式サイト](https://aws.amazon.com/bottlerocket/)
- [Bottlerocket GitHub](https://github.com/bottlerocket-os/bottlerocket)
- [Bottlerocket Documentation](https://bottlerocket.dev/)
- [Bottlerocket Security Features](https://github.com/bottlerocket-os/bottlerocket/blob/develop/SECURITY_FEATURES.md)
- [AWS — Using Bottlerocket on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami-bottlerocket.html)
- [AWS — Using Bottlerocket on Amazon ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/bottlerocket.html)
- [apiclient リファレンス](https://bottlerocket.dev/en/os/1.20.x/api/apiclient/)
