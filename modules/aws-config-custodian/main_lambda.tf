# c7n 本体。PyPI の wheel（zip 形式）をそのまま layer にする。ポリシーが増えても layer は 1 つ。
resource "aws_lambda_layer_version" "c7n" {
  layer_name          = "cloud-custodian"
  description         = "c7n ${local.c7n_version} (PyPI wheel as-is)"
  filename            = local.c7n_wheel
  source_code_hash    = filebase64sha256(local.c7n_wheel)
  compatible_runtimes = [local.runtime]
}

# ポリシーごとの Lambda コード。中身はハンドラと config.json の 2 ファイルだけ。
data "archive_file" "policy" {
  for_each = local.policies

  type        = "zip"
  output_path = "${path.module}/.build/${each.key}.zip"

  source {
    filename = "custodian_policy.py"
    content  = file("${path.module}/src/custodian_policy.py")
  }

  source {
    filename = "config.json"
    content  = local.policy_configs[each.key]
  }
}

resource "aws_cloudwatch_log_group" "policy" {
  for_each = local.policies

  name              = "/aws/lambda/custodian-${each.key}"
  retention_in_days = var.log_retention_in_days
}

resource "aws_lambda_function" "policy" {
  for_each = local.policies

  function_name    = "custodian-${each.key}"
  description      = try(each.value.description, "cloud-custodian config rule")
  filename         = data.archive_file.policy[each.key].output_path
  source_code_hash = data.archive_file.policy[each.key].output_base64sha256
  handler          = "custodian_policy.run"
  runtime          = local.runtime
  layers           = [aws_lambda_layer_version.c7n.arn]
  role             = aws_iam_role.custodian.arn
  # c7n がデプロイするときの既定値に合わせる
  memory_size = 512
  timeout     = 900

  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.policy[each.key].name
  }
}

resource "aws_lambda_permission" "config" {
  for_each = local.policies

  statement_id   = "AllowConfigInvoke"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.policy[each.key].function_name
  principal      = "config.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
}
