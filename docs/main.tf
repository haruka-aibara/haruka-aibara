provider "aws" {
    profile = "default"
    region = "ap-northeast-1"
}

resource "aws_instance" "hello-world" {
    ami = "ami-031134f7a79b6e424"
    instance_type = "t2.micro"

    tags = {
        Name = "HelloWorld"
    }
}