# その他のレジストリ（GHCR・ECR・ACR・GAR 等）

業務のイメージを Docker Hub に置くことはまずない。プライベート性・権限管理・自社クラウドとの近さから、**組織のインフラに合わせたレジストリ**を使う。どれも OCI 標準（[01-04](../01_Docker_イントロダクション/01-04_DockerとOCI.md)）なので操作は同じで、違いは認証と周辺機能に出る。

## 主要どころと選び方

| レジストリ | 提供元 | 選ばれる場面 |
|---|---|---|
| **ECR** | AWS | AWS で動かすなら実質これ。IAM で権限管理、ECS/EKS との統合 |
| **GHCR** (ghcr.io) | GitHub | コードが GitHub にあるなら最短。GitHub Actions との相性、OSS 配布 |
| **GAR** (Artifact Registry) | Google | GCP 版。旧 GCR の後継 |
| **ACR** | Azure | Azure 版 |
| **Harbor** 等 | セルフホスト | オンプレ・エアギャップ環境、レジストリ自体を統制したい組織 |

判断基準はシンプルで、**「イメージを使う場所（実行基盤）に一番近いところ」**に置く。pull の速さ・転送コスト・権限管理の一貫性がすべてそこで決まる。

## ECR を例に：クラウドレジストリの型

```bash
# 認証（IAM 認証情報から一時トークンを取得して docker login する）
aws ecr get-login-password --region ap-northeast-1 | \
  docker login --username AWS --password-stdin 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com

# push はフル名で
docker tag myapp:1.4.2 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/myapp:1.4.2
docker push 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/myapp:1.4.2
```

クラウドレジストリ共通の型は「**docker login のパスワードをクラウドの認証基盤から動的に発行する**」こと。恒久的なパスワードを CI に埋め込まず、IAM ロール（GitHub Actions なら OIDC 連携）で認証するのが現代の標準で、レジストリの認証情報漏洩という古典的事故を構造的に潰せる。

## レジストリ側の機能を使い倒す

置き場所以上の価値がある機能群。特にセキュリティ運用に直結するもの：

- **脆弱性スキャン**：push 時に自動スキャン（ECR は Inspector 連携）。「ビルドしたら自動で検査される」パイプラインが作れる
- **ライフサイクルポリシー**：古いイメージの自動削除。放置すると数百GBの残骸とストレージ課金が育つ
- **pull through cache**：Docker Hub のミラーとして機能し、レート制限（[08-03](08-03_Dockerhub.md)）と外部依存を切れる
- **タグ不変設定・署名検証**：すり替え防止（[08-01](08-01_イメージタグ付けのベストプラクティス.md)）

## 参考

- [Amazon ECR — AWS Documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
- [GitHub Container Registry — GitHub Docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Harbor](https://goharbor.io/)
