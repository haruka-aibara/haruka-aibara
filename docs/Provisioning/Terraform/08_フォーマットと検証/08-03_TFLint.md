<!-- Space: harukaaibarapublic -->
<!-- Parent: 08_フォーマットと検証 -->
<!-- Title: TFLint -->

# TFLint

`terraform validate` では検出できないベストプラクティス違反や、プロバイダー固有の問題を検出する静的解析ツール。

---

## インストール

```bash
# macOS
brew install tflint

# Linux
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
```

---

## 初期化と実行

```bash
# プロバイダープラグインのインストール（初回・プロバイダー追加時）
tflint --init

# カレントディレクトリをチェック
tflint

# 再帰的にチェック
tflint --recursive
```

---

## 設定ファイル（.tflint.hcl）

```hcl
plugin "aws" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_instance_invalid_type" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}
```

---

## 検出できる問題の例

```
1 issue(s) found:

Warning: "t1.micro" is an invalid value as instance_type (aws_instance_invalid_type)

  on main.tf line 3:
   3:   instance_type = "t1.micro"

Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
```

- 廃止済みのインスタンスタイプの使用
- 非推奨な HCL 構文（`"${var.foo}"` → `var.foo` など）
- 必須タグの欠落（カスタムルールで設定可能）
- 未使用の変数

---

## CI/CD への組み込み

```yaml
- name: TFLint
  run: |
    tflint --init
    tflint --recursive
```

`terraform fmt` → `terraform validate` → `tflint` の順でチェックするのが定番。
