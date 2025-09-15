# AWS 프로바이더 설정
# Terraform이 AWS 서비스와 통신할 수 있게 해주는 플러그인입니다
provider "aws" {
    region = "us-east-1"  # AWS 리전 설정 (미국 동부 1)
}

# AMI 변수 정의
# Amazon Machine Image ID를 설정하는 변수입니다
variable "ami" {
  description = "This is AMI for the instance"  # 인스턴스용 AMI입니다
}

# 인스턴스 타입 변수 정의
# EC2 인스턴스의 성능을 결정하는 변수입니다
variable "instance_type" {
  description = "This is the instance type, for example: t2.micro"  # 인스턴스 타입입니다 (예: t2.micro)
}

# EC2 인스턴스 리소스 정의
# AWS의 가상 서버를 생성합니다
resource "aws_instance" "example" {
    ami = var.ami           # Amazon Machine Image (서버 템플릿)
    instance_type = var.instance_type  # 인스턴스 타입 (CPU, 메모리 사양)
}