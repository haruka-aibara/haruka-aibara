<!-- Space: harukaaibarapublic -->
<!-- Parent: 15_プロビジョナー -->
<!-- Title: local-exec プロビジョナー -->

# local-exec プロビジョナー

Terraform を実行しているローカルマシン（または CI ランナー）でコマンドを実行するプロビジョナー。SSH 不要なのでプロビジョナーの中では比較的使いやすい。

---

## 基本的な使い方

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> ./ip_list.txt"
  }
}
```

---

## よく使うオプション

```hcl
provisioner "local-exec" {
  command     = "./register.sh"
  interpreter = ["/bin/bash", "-c"]     # シェルを明示
  working_dir = "/tmp"                   # 実行ディレクトリ
  environment = {
    INSTANCE_ID = self.id
    REGION      = var.aws_region
  }
}
```

---

## 実務での用途

### 外部サービスへの登録

Terraform プロバイダーが存在しない独自システムに curl で登録する場合など。

```hcl
provisioner "local-exec" {
  command = <<-EOT
    curl -X POST https://internal-registry.example.com/instances \
      -H "Authorization: Bearer ${var.api_token}" \
      -d '{"id": "${self.id}", "ip": "${self.public_ip}"}'
  EOT
}
```

### Ansible のキック

```hcl
provisioner "local-exec" {
  command = "ansible-playbook -i '${self.public_ip},' playbook.yml"
}
```

---

## 注意点

- 実行結果は State に記録されない。`terraform apply` を再実行しても冪等にならない
- `when = destroy` と組み合わせて削除時の後処理にも使える
- Windows 環境では `interpreter = ["PowerShell", "-Command"]` に変える必要がある
