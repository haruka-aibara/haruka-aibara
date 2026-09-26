# ネットワークモジュール
module "network" {
  source = "./modules/network"

  name_prefix        = "grafana"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  availability_zone  = "ap-northeast-1a"
}

# Grafanaモジュール
module "grafana" {
  source = "./modules/grafana"

  name_prefix   = "grafana"
  vpc_id        = module.network.vpc_id
  subnet_id     = module.network.public_subnet_id
  ami_id        = "ami-0c1638aa346a43fe8" # Amazon Linux 2023
  instance_type = "t2.micro"
}

# Exporterモジュール
module "exporter" {
  source = "./modules/exporter"

  name_prefix   = "exporter"
  vpc_id        = module.network.vpc_id
  subnet_id     = module.network.public_subnet_id
  ami_id        = "ami-0c1638aa346a43fe8" # Amazon Linux 2023
  instance_type = "t2.micro"
}
