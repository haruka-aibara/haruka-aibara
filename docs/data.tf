data "aws_prefix_list" "s3_pl" {
  name = "com.amazonaws.*.s3"
}