# Compute Engine (GCE)

Google Compute Engine（GCE）は、GCPの仮想マシン（VM）サービスです。AWSのEC2に相当します。

## 主な特徴

- **仮想マシンインスタンス**: LinuxやWindowsのVMを作成・管理
- **カスタムマシンタイプ**: CPUやメモリを柔軟に設定可能
- **永続ディスク**: データを保存するブロックストレージ
- **ネットワーク**: VPCでのネットワーク接続

## 基本的な用語

- **インスタンス**: 仮想マシンそのもの
- **マシンタイプ**: CPUとメモリの組み合わせ（例: `e2-micro`, `n1-standard-1`）
- **イメージ**: OSのテンプレート（例: Ubuntu、Debian、Windows Server）
- **ディスク**: インスタンスのストレージ（永続ディスク、ローカルSSD）
- **ゾーン**: インスタンスを配置する物理ロケーション

## 事前準備

### APIの有効化

GCEを使用するには、Compute Engine APIを有効化する必要があります。

```hcl
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}
```

または、gcloud CLIから：

```bash
gcloud services enable compute.googleapis.com --project=YOUR_PROJECT_ID
```

## インスタンスの作成

### Terraformで作成

```hcl
resource "google_compute_instance" "example" {
  name         = "example-instance"
  machine_type = "e2-micro"
  zone         = "asia-northeast1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
    }
  }

  network_interface {
    network = "default"
    access_config {
      // 外部IPを付与（削除すると内部IPのみ）
    }
  }
}
```

### gcloud CLIで作成

```bash
gcloud compute instances create example-instance \
  --zone=asia-northeast1-a \
  --machine-type=e2-micro \
  --image-family=debian-11 \
  --image-project=debian-cloud
```

## よく使うマシンタイプ

- **e2-micro**: 無料枠対応、開発・テスト用（0.25 vCPU、1GB RAM）
- **e2-small**: 軽量ワークロード（0.5 vCPU、2GB RAM）
- **e2-standard-2**: 標準的な用途（2 vCPU、8GB RAM）
- **n1-standard-1**: 従来型のマシンタイプ（1 vCPU、3.75GB RAM）

## 重要な注意事項

1. **ゾーンの指定**: インスタンスは特定のゾーンに作成される
2. **外部IP**: デフォルトで外部IPが付与される（不要な場合は削除）
3. **ファイアウォール**: デフォルトのファイアウォールルールで通信が制限される場合がある
4. **コスト**: インスタンスを停止してもディスクの料金は発生する

## その他のリソース

- **インスタンスグループ**: 複数のインスタンスを管理
- **ロードバランサー**: トラフィックの分散
- **自動スケーリング**: 負荷に応じて自動的にインスタンス数を調整

