# Nomad

「Kubernetes は複雑すぎる。でも Swarm は先細り。他にないのか」——第三の選択肢として名前が挙がるのが HashiCorp の **Nomad**。Terraform・Vault と同じ HashiCorp 製のワークロードオーケストレータで、「シンプルさ重視の Kubernetes 代替」というポジション。

## 特徴：単一バイナリ、コンテナ以外も動かせる

- **単一バイナリで完結**：サーバーにバイナリを置いて起動すればクラスタが組める。Kubernetes のようなコンポーネント群（etcd、API サーバー、各種コントローラ…）の運用がない
- **コンテナ専用ではない**：Docker コンテナに加えて、**素の実行ファイル、Java アプリ、QEMU VM** などもスケジューリングできる。「コンテナ化されていないレガシーも同じ基盤に載せたい」に効く、Kubernetes にはない芸当
- **HashiCorp スタックとの統合**：Consul（サービスディスカバリ）、Vault（秘密管理）と組み合わせる設計。Terraform ユーザーには馴染む HCL でジョブを書く

```hcl
job "api" {
  datacenters = ["dc1"]
  group "api" {
    count = 3
    task "server" {
      driver = "docker"
      config {
        image = "myapp:1.4.2"
        ports = ["http"]
      }
      resources { cpu = 500, memory = 512 }
    }
  }
}
```

compose や Kubernetes マニフェストと見比べると、概念（イメージ・レプリカ数・リソース制限）は共通で、記法が違うだけと分かる。

## 現在地と採用判断

実運用の採用例はある（大規模事例も存在する）が、エコシステムの厚みとマネージドサービスの有無で Kubernetes に大きく水をあけられているのが実情。また、ライセンスが BSL に変更された点（Terraform と同時期）は、OSS 前提で選定する場合の確認事項。

判断の整理：

- クラウドでの標準的なコンテナ運用 → ECS か マネージド Kubernetes が無難
- **オンプレで、コンテナと非コンテナが混在し、運用チームが小さい** → Nomad が刺さる数少ない条件
- HashiCorp スタック（Consul/Vault）に既に投資している組織 → 相乗効果あり

Docker 学習の文脈では「オーケストレータは Kubernetes 一択ではなく、要件次第で選択肢がある」ことを知るための参照点、という位置づけで十分。

## 参考

- [Nomad — HashiCorp Developer](https://developer.hashicorp.com/nomad)
- [Nomad vs. Kubernetes — HashiCorp Developer](https://developer.hashicorp.com/nomad/docs/nomad-vs-kubernetes)
