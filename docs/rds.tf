# ------------------------
# RDS parameter group
# ------------------------
resource "aws_db_parameter_group" "mysql_standalone_parametergroup" {
  name   = "${var.project}-${var.environment}-mysql-standalone-parametergroup"
  family = "mysql8.0"

  parameter {
    name  = "character_set_database"
    value = "utf8bm4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8bm4"
  }
}