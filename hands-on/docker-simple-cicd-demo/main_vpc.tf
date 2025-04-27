# VPC関連のリソース
resource "aws_vpc" "simple_cicd" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "simple-cicd-vpc"
  }
}

# パブリックサブネット（少なくとも2つ必要です - 可用性確保のため）
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.simple_cicd.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a" # お使いのリージョンに合わせて変更してください
  map_public_ip_on_launch = true

  tags = {
    Name = "simple-cicd-public-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.simple_cicd.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c" # お使いのリージョンに合わせて変更してください
  map_public_ip_on_launch = true

  tags = {
    Name = "simple-cicd-public-2"
  }
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "simple_cicd" {
  vpc_id = aws_vpc.simple_cicd.id

  tags = {
    Name = "simple-cicd-igw"
  }
}

# ルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.simple_cicd.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.simple_cicd.id
  }

  tags = {
    Name = "simple-cicd-rt-public"
  }
}

# サブネットとルートテーブルの関連付け
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}
