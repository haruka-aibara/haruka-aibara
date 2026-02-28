<!-- Space: harukaaibarapublic -->
<!-- Parent: 01_Terraformのイントロダクション -->
<!-- Title: Terraform のインストール -->

# Terraform のインストール

---

## tfenv（推奨）

バージョン管理ツール。プロジェクトごとに Terraform バージョンを切り替えられる。

```bash
# macOS
brew install tfenv

tfenv install 1.9.0
tfenv use 1.9.0

terraform -version
# Terraform v1.9.0
```

`.terraform-version` ファイルをリポジトリに置けば `tfenv install` で自動インストールされる。

```
# .terraform-version
1.9.0
```

---

## 直接インストール

### macOS

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### Linux（Ubuntu / Debian）

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### Windows

```powershell
winget install HashiCorp.Terraform
```

---

## CI/CD（GitHub Actions）

```yaml
- uses: hashicorp/setup-terraform@v3
  with:
    terraform_version: "1.9.0"
```
