
provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "terra-stage-3" {
  ami           = var.ami_value
  instance_type = var.instance_type_value
  subnet_id = var.subnet_id_value

  tags = {
    Name = "terra-stage-3"
  }
  
  # Public IP 할당 활성화
  associate_public_ip_address = true
}