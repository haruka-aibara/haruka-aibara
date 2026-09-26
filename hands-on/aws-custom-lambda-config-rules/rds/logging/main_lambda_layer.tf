# S3バケットの作成（Lambdaレイヤー用）
resource "aws_s3_bucket" "lambda_layer_bucket" {
  bucket = "haruka-aibara-lambda-layer-bucket"
}

# RDKlibを含むLambdaレイヤーのパッケージングとアップロード
resource "null_resource" "prepare_rdk_layer" {
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p build/python
      uv pip install rdklib --target build/python
      cd build && zip -r9 ../rdklib_layer.zip .
      aws s3 cp ../rdklib_layer.zip s3://${aws_s3_bucket.lambda_layer_bucket.id}/rdklib_layer.zip
    EOT
  }
}

# Lambdaレイヤーの作成
resource "aws_lambda_layer_version" "rdklib_layer" {
  layer_name          = "rdklib"
  s3_bucket           = aws_s3_bucket.lambda_layer_bucket.id
  s3_key              = "rdklib_layer.zip"
  compatible_runtimes = ["python3.8"]
  depends_on          = [null_resource.prepare_rdk_layer]
}
