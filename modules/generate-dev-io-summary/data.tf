# works から module として呼ぶので、パスは path.module で明示的にアンカーする。
# ベタの相対パスだと works ルートからの相対になってしまう。
# Lambda Layer の中身（requests / beautifulsoup4）は lambda_functions/lambda_layer/python に
# コミット済み。requirements.txt を変えたら、同じディレクトリに pip install -t し直す。
# zip の出力先は source_dir の外（.build/）に置く。中に置くと前回の zip が次の zip に
# 入り込み、source_code_hash が plan のたびに変わる。

# Lambda Layer用のzipファイルのアーカイブを作成
data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/lambda_layer"
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
