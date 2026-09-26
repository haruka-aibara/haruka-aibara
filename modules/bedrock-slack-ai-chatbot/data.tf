# 現在の AWS アカウント情報を取得するデータソース
data "aws_caller_identity" "current" {}

# 現在の AWS リージョン情報を取得するデータソース
data "aws_region" "current" {}

# zip の出力先は source_dir の外（.build/）に置く。中に置くと前回の zip が次の zip に
# 入り込み、source_code_hash が plan のたびに変わる。
#
# Lambda Layer用のzipファイルのアーカイブを作成
# path.module で明示的にアンカーする。ベタの相対パスだと works ルートからの
# CWD 基準で解決され、子モジュール化した現在は解決先が存在しないディレクトリに
# なってしまう(単体ルートモジュールだった頃は CWD == path.module で偶然一致していた)。
data "archive_file" "lambda_layer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_layer"
  output_path = "${path.module}/.build/lambda_layer.zip"
}

# Lambda関数のコードをzip化
data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function_slack_ai_chatbot"
  output_path = "${path.module}/.build/lambda_function_slack_ai_chatbot.zip"
}

# Lambda関数のコードをzip化
data "archive_file" "lambda_bedrock_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function_bedrock_backend"
  output_path = "${path.module}/.build/lambda_function_bedrock_backend.zip"
}
