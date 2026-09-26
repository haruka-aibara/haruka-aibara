# works から module として呼ぶので、パスは path.module で明示的にアンカーする。
# ベタの相対パスだと works ルートからの相対になってしまう。
# Lambda Layer の中身（requests / beautifulsoup4）はコミットせず、requirements.txt から
# plan のたびに build_layer.py が pip で .build/lambda_layer に作る。
# zip の出力先は source_dir の外（.build/）に置く。中に置くと前回の zip が次の zip に
# 入り込み、source_code_hash が plan のたびに変わる。

# Lambda Layer用のzipファイルのアーカイブを作成
data "external" "lambda_layer" {
  program = ["python3", "${path.module}/build_layer.py"]
}

data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = data.external.lambda_layer.result.dir
  output_path = "${path.module}/.build/lambda_layer.zip"
}

# Lambda関数のコードをzip化
data "archive_file" "lambda_scraper" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/scraper"
  output_path = "${path.module}/.build/lambda_function_scraper.zip"
}

# Lambda関数のコードをzip化
data "archive_file" "lambda_summarizer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/summarizer"
  output_path = "${path.module}/.build/lambda_function_summarizer.zip"
}
