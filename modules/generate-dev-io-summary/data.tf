# works から module として呼ぶので、パスは path.module で明示的にアンカーする。
# ベタの相対パスだと works ルートからの相対になってしまう。
# Lambda Layer の中身（requests / beautifulsoup4）は lambda_functions/lambda_layer/python に
# コミット済み。requirements.txt を変えたら、同じディレクトリに pip install -t し直す。

# Lambda Layer用のzipファイルのアーカイブを作成
data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/lambda_layer"
  output_path = "${path.module}/lambda_functions/lambda_layer/lambda_layer.zip"
}

# Lambda関数のコードをzip化
data "archive_file" "lambda_scraper" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/scraper"
  output_path = "${path.module}/lambda_functions/scraper/lambda_function.zip"
}

# Lambda関数のコードをzip化
data "archive_file" "lambda_summarizer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/summarizer"
  output_path = "${path.module}/lambda_functions/summarizer/lambda_function.zip"
}
