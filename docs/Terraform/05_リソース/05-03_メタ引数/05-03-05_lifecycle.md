<!-- Space: harukaaibarapublic -->
<!-- Parent: 05-03_メタ引数 -->
<!-- Title: lifecycle -->

# lifecycle

リソースの作成・更新・削除の挙動をカスタマイズするメタ引数。

---

## create_before_destroy

デフォルトは「削除してから作成」だが、このオプションを使うと「作成してから削除」の順になる。ダウンタイムを減らしたい場合に有効。

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true
  }
}
```

---

## prevent_destroy

`terraform destroy` や設定削除で誤ってリソースが削除されるのを防ぐ。削除しようとするとエラーになる。

```hcl
resource "aws_db_instance" "main" {
  ...
  lifecycle {
    prevent_destroy = true
  }
}
```

本番 DB や重要リソースに設定しておくと誤操作防止になる。

---

## ignore_changes

外部から変更される属性を Terraform 管理から除外する。次回 apply 時に差分として検出しなくなる。

```hcl
resource "aws_autoscaling_group" "app" {
  desired_capacity = 2
  ...

  lifecycle {
    ignore_changes = [desired_capacity]  # Auto Scaling による変更を無視
  }
}
```

`ignore_changes = all` で全属性を無視することもできるが、実質的に Terraform 管理から外れるため注意。

---

## replace_triggered_by（v1.2+）

指定した別リソースや属性が変更された時に、このリソースを強制 replace する。

```hcl
resource "aws_instance" "web" {
  ...
  lifecycle {
    replace_triggered_by = [aws_security_group.web.id]
  }
}
```
