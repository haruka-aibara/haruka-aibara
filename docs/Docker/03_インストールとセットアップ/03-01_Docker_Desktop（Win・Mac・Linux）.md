# Docker Desktop（Win・Mac・Linux）

Mac や Windows で Docker を使うとき、実は「その OS の上で直接コンテナが動いている」わけではない。Docker Desktop の実体を知らないと、ファイル共有の遅さ・メモリの张り付き・ライセンス問題という3大ハマりポイントで混乱する。

## 実体：Linux VM ＋ GUI ＋ CLI 連携

コンテナはホストと Linux カーネルを共有するプロセスなので（[01-01](../01_Docker_イントロダクション/01-01_コンテナとは何か.md)）、**Linux 以外の OS では Linux VM が必須**。Docker Desktop は：

- 裏で軽量 Linux VM を起動し（Mac は Apple の仮想化フレームワーク、Windows は WSL 2）
- その VM 内で Docker エンジンを動かし
- ホストの `docker` CLI からシームレスに見えるよう配線し
- GUI・自動アップデート・Kubernetes 同梱などを付けたパッケージ

つまり Mac/Windows での docker コマンドは、常に「VM 内の Docker」へのリモート操作になっている。

## この構造から来るハマりポイント

- **バインドマウントが遅い**：`-v $PWD:/app` は「ホスト↔VM のファイル共有」を経由するため、Linux ネイティブより桁で遅いことがある。node_modules のような大量小ファイルで顕著。対策は名前付きボリュームに逃がす、または Windows なら**プロジェクトを WSL 2 ファイルシステム側に置く**
- **メモリを食う**：VM に割り当てた分は使っていなくても確保される。Settings → Resources で割当を調整する
- **「localhost」の意味**：コンテナは VM 内にいるが、ポート公開（`-p`）はホストの localhost に配線してくれるので普段は意識不要。逆にコンテナからホスト側のサービスを呼ぶときは `host.docker.internal` を使う

## ライセンス：会社で使うなら確認必須

Docker Desktop は**一定規模以上の企業での利用は有料**（従業員数・売上の閾値あり。個人・小規模は無料）。「docker コマンド＝無料」の感覚で会社の PC に入れるとコンプライアンス問題になり得る。組織で配るなら、ライセンス購入か、無料代替（Linux なら Docker Engine 単体（[03-02](03-02_Dockerエンジン（Linux）.md)）、Mac なら colima、あるいは Podman Desktop 等）の検討が必要。OCI 標準（[01-04](../01_Docker_イントロダクション/01-04_DockerとOCI.md)）のおかげで代替への乗り換えコストは低い。

## 参考

- [Docker Desktop — Docker Docs](https://docs.docker.com/desktop/)
- [Docker Desktop license agreement — Docker Docs](https://docs.docker.com/subscription/desktop-license/)
- [colima — GitHub](https://github.com/abiosoft/colima)
