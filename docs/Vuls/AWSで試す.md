# Vuls を AWS 環境で試す

## 前提と構成

「手元のサーバーのパッケージに脆弱性があるか確認したい」というとき、Vuls は SSH でターゲットに接続してパッケージ一覧を収集し CVE DB と照合する。

AWS では **SSH over SSM**（Session Manager）を使うのが現代的。セキュリティグループでインバウンド 22 番を開けなくていいので、プライベートサブネットの EC2 も踏み台なしでスキャンできる。

```
[スキャナー EC2]  --SSH over SSM--> [スキャン対象 EC2]
  vulsctl + Docker                    SSM Agent 起動済み
  AWS CLI + SSM plugin                AmazonSSMManagedInstanceCore
  ~/.ssh/config: ProxyCommand 設定
```

---

## Terraform でテスト環境を作る

```hcl
# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# スキャナー用 IAM ロール（SSM StartSession 権限あり）
resource "aws_iam_role" "vuls_scanner" {
  name = "vuls-scanner-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "scanner_ssm_core" {
  role       = aws_iam_role.vuls_scanner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "scanner_start_session" {
  role = aws_iam_role.vuls_scanner.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssm:StartSession",
        "ssm:TerminateSession",
        "ssm:ResumeSession",
        "ssm:DescribeSessions",
        "ssm:GetConnectionStatus",
        "ec2:DescribeInstances"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "vuls_scanner" {
  name = "vuls-scanner-profile"
  role = aws_iam_role.vuls_scanner.name
}

# スキャン対象用 IAM ロール（SSM Agent 用）
resource "aws_iam_role" "vuls_target" {
  name = "vuls-target-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "target_ssm_core" {
  role       = aws_iam_role.vuls_target.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "vuls_target" {
  name = "vuls-target-profile"
  role = aws_iam_role.vuls_target.name
}

# セキュリティグループ（インバウンド SSH 不要）
resource "aws_security_group" "vuls" {
  name   = "vuls-sg"
  vpc_id = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# スキャナー EC2
resource "aws_instance" "scanner" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.small"
  subnet_id              = data.aws_subnets.default.ids[0]
  iam_instance_profile   = aws_iam_instance_profile.vuls_scanner.name
  vpc_security_group_ids = [aws_security_group.vuls.id]

  user_data = <<-EOF
    #!/bin/bash
    # Docker インストール
    dnf install -y docker git
    systemctl enable --now docker
    usermod -aG docker ec2-user

    # AWS CLI v2 はデフォルト入り
    # Session Manager plugin
    dnf install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm

    # vulsctl を取得
    git clone https://github.com/vulsio/vulsctl.git /home/ec2-user/vulsctl
    chown -R ec2-user:ec2-user /home/ec2-user/vulsctl

    # SSH キーペアを生成（スキャン対象への接続用）
    sudo -u ec2-user ssh-keygen -t rsa -b 4096 -N "" -f /home/ec2-user/.ssh/id_rsa
  EOF

  tags = { Name = "vuls-scanner" }
}

# スキャン対象 EC2
resource "aws_instance" "target" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.default.ids[0]
  iam_instance_profile   = aws_iam_instance_profile.vuls_target.name
  vpc_security_group_ids = [aws_security_group.vuls.id]

  tags = { Name = "vuls-target" }
}

output "scanner_instance_id" {
  value = aws_instance.scanner.id
}

output "target_instance_id" {
  value = aws_instance.target.id
}
```

---

## セットアップ手順

### 1. スキャナーに公開鍵をターゲットへ登録

```bash
# スキャナー EC2 に SSM でログイン
aws ssm start-session --target <scanner-instance-id>

# 公開鍵を確認
cat ~/.ssh/id_rsa.pub
```

取得した公開鍵をターゲット EC2 の `authorized_keys` に登録する：

```bash
# 別ターミナルから ターゲット EC2 にログイン
aws ssm start-session --target <target-instance-id>

# vuls ユーザーを作成して公開鍵を登録
sudo useradd -m vuls
sudo mkdir -p /home/vuls/.ssh
echo "ssh-rsa AAAA..." | sudo tee /home/vuls/.ssh/authorized_keys
sudo chmod 600 /home/vuls/.ssh/authorized_keys
sudo chown -R vuls:vuls /home/vuls/.ssh
```

### 2. スキャナーで SSH config を設定

```bash
# スキャナー EC2 上で
cat >> ~/.ssh/config << 'EOF'
Host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
    User vuls
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
EOF
chmod 600 ~/.ssh/config
```

### 3. DB を取得する

```bash
cd ~/vulsctl/docker

# Amazon Linux 2023 の OVAL データ（数分）
./oval.sh --amazon

# NVD の CVE データ（30 分〜1 時間）
./cvedb.sh --nvd

# RedHat 系セキュリティトラッカー（数分）
./gost.sh --redhat
```

### 4. config.toml を作成

```bash
cat > ~/vulsctl/docker/config.toml << EOF
[default]
port     = "22"
user     = "vuls"
keyPath  = "/root/.ssh/id_rsa"
sshConfigPath = "/root/.ssh/config"
scanMode = ["fast"]

[cveDict]
type        = "sqlite3"
sqlite3Path = "/vuls/go-cve-dictionary.sqlite3"

[ovalDict]
type        = "sqlite3"
sqlite3Path = "/vuls/goval-dictionary.sqlite3"

[gost]
type        = "sqlite3"
sqlite3Path = "/vuls/gost.sqlite3"

[servers]

[servers.target]
host = "$(terraform output -raw target_instance_id)"
port = "22"
EOF
```

### 5. スキャン実行

```bash
cd ~/vulsctl/docker

./scan.sh
./report.sh
./tui.sh   # ターミナル上でインタラクティブに結果確認
```

---

## よくある失敗

| エラー | 原因と対処 |
|--------|-----------|
| `dial tcp: connect refused` | ターゲット EC2 の SSM Agent が起動していない。`systemctl status amazon-ssm-agent` で確認 |
| `Permission denied (publickey)` | ターゲットの `authorized_keys` に公開鍵が入っていない |
| `An error occurred: StartSession... not authorized` | スキャナーの IAM ロールに `ssm:StartSession` がない |
| DB が空で CVE が 0 件 | `./cvedb.sh --nvd` がまだ終わっていない。NVD の取得に 30 分〜1 時間かかる |

---

## 後片付け

```bash
terraform destroy
```

DB の取得（特に `--nvd`）が時間かかるのが Vuls のセットアップで一番ハマるポイント。先に `./oval.sh --amazon` だけ流しておいて、`./cvedb.sh --nvd` をバックグラウンドで走らせながら他の設定を進めるのが効率的。
