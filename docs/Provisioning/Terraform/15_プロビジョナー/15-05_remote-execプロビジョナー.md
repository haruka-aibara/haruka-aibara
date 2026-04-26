<!-- Space: harukaaibarapublic -->
<!-- Parent: 15_プロビジョナー -->
<!-- Title: remote-exec プロビジョナー -->

# remote-exec プロビジョナー

リモートマシンに SSH（または WinRM）で接続してコマンドを実行するプロビジョナー。EC2 インスタンスに直接スクリプトを実行したいときに使う。

---

## 基本的な使い方

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
    ]
  }
}
```

---

## 3つの実行方法

### inline

コマンドを配列で列挙。

```hcl
provisioner "remote-exec" {
  inline = [
    "echo 'start'",
    "sudo apt-get install -y curl",
  ]
}
```

### script

ローカルのスクリプトファイルをリモートに転送して実行。

```hcl
provisioner "remote-exec" {
  script = "scripts/setup.sh"
}
```

### scripts

複数のスクリプトを順番に実行。

```hcl
provisioner "remote-exec" {
  scripts = [
    "scripts/01_install.sh",
    "scripts/02_configure.sh",
  ]
}
```

---

## connection ブロック

`remote-exec` には必ず接続設定が必要。

```hcl
connection {
  type     = "ssh"
  user     = "ubuntu"
  password = var.instance_password   # またはキーペア
  host     = self.public_ip
  timeout  = "5m"                    # 接続タイムアウト
}
```

---

## 注意点

- インスタンスが起動してから SSH が使えるまで時間がかかる。`timeout` を余裕をもって設定する
- パブリック IP が必要になるケースが多い。プライベートサブネットのインスタンスには使いにくい
- CI/CD 環境では SSH キーの管理・セキュリティグループ設定が複雑になる
- EC2 の初期設定なら User Data を使う方が推奨
