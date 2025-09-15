# AWS 프로바이더 설정
# 프로바이더는 Terraform이 AWS와 통신할 수 있게 해주는 플러그인입니다
provider "aws" {
    region = "ap-northeast-2"  # 서울 리전
}

# EC2 인스턴스 리소스 정의
# aws_instance는 AWS의 가상 서버를 나타냅니다
# resource "aws_instance" "example" {
#     ami           = "ami-0c55b159cbfafe1f0"  # 적절한 AMI ID를 지정하세요 (서버의 템플릿)
#     instance_type = "t2.micro"  # 인스턴스 타입 (CPU, 메모리 크기)
# } 

resource "aws_instance" "this" {
  ami                     = "ami-0662f4965dfc70aca"
  instance_type           = "t2.micro"
  subnet_id               = "subnet-0e365d060c45b810b"
  key_name                = "terraform-test-key"
  
  tags                    = {
    Name = "terraform-test-instance"
  }
}