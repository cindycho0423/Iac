provider "aws" {
  region = "us-east-1"  # AWS 리전 설정 (미국 동부 1)
}

variable "ami" {
  description = "value"  # 변수 설명
}

variable "instance_type" {
  description = "value"  # 변수 설명
  type = map(string)     # 맵 타입 (키-값 쌍)

  default = {
    "dev" = "t2.micro"    # 개발 환경: 작은 인스턴스
    "stage" = "t2.medium"  # 스테이징 환경: 중간 인스턴스
    "prod" = "t2.xlarge"   # 프로덕션 환경: 큰 인스턴스
  }
}

module "ec2_instance" {
  source = "./modules/ec2_instance"
  ami = var.ami
  instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro")
}