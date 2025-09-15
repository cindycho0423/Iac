provider "aws" {
  region = "ap-northeast-2"
}

module "ec2_instance" {
  source = "./modules/ec2_instance"
  ami_value = "ami-0662f4965dfc70aca"
  instance_type_value = "t2.micro"
  subnet_id_value = "subnet-0e365d060c45b810b"
}
