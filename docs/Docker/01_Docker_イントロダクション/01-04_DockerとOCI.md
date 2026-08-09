# DockerとOCI

「Docker でビルドしたイメージは Kubernetes（containerd）でも Podman でも動く」「ECR にも GHCR にも同じように push できる」——当たり前に見えるこの互換性は自然にあるものではなく、**OCI（Open Container Initiative）という標準化**の成果。この構図を知っておくと、「Docker が使えない環境」でも何も怖くなくなる。

## OCI が標準化した3つ

OCI は 2015 年に Docker 社などが設立したコンテナ標準化団体で、Docker が事実上の標準だった仕様を切り出して中立化した。主要な仕様は3つ：

- **Image Spec**: イメージの形式（レイヤー、マニフェスト、設定）。「docker build したものが他のツールでも動く」の根拠
- **Runtime Spec**: コンテナの実行仕様。参照実装が **runc** で、Docker も containerd も CRI-O も最終的にこれ（互換ランタイム）を呼ぶ
- **Distribution Spec**: レジストリとの push/pull のプロトコル。Docker Hub・ECR・GHCR が同じコマンドで使える根拠

つまり「コンテナイメージ」と呼んでいるものの実体は **OCI イメージ**であり、Docker はそれを作る・動かすツールの1つ、という関係になっている。

## この構図が効いてくる場面

- **Kubernetes ノードに Docker がない**: kubelet は containerd を直接使う。でもイメージは OCI 標準なので、Docker でビルドしたものがそのまま動く。「Kubernetes の Docker 非推奨」で何も壊れなかったのはこのため
- **Docker Desktop のライセンス問題**: 企業利用の有料化を機に Podman 等の代替に乗り換えた組織は多い。OCI 準拠なので Dockerfile もイメージもほぼそのまま使える
- **ビルドツールの選択肢**: docker build 以外にも BuildKit、Buildah、kaniko（クラスタ内ビルド）など、OCI イメージを作る手段は複数ある。CI 環境の制約（Docker デーモンを動かせない等）に応じて差し替えられる

要するに、**学ぶべき本体は「OCI エコシステムの概念」**（イメージ・レイヤー・レジストリ・ランタイム）で、Docker はその最も普及した入口。概念を押さえていればツールの乗り換えはコストにならない。

ランタイム側の階層構造（containerd / runc / CRI-O の関係）は Linux 側の [コンテナランタイム](../../Linux/16_コンテナ化/16-03_コンテナランタイム.md) にまとめてある。

## 参考

- [Open Container Initiative](https://opencontainers.org/)
- [OCI Image Format Specification — GitHub](https://github.com/opencontainers/image-spec)
- [containerd — containerd.io](https://containerd.io/)
