provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "terraform-stage-4" {
  instance_type = "t2.micro" 
  ami = "ami-0662f4965dfc70aca" 
  subnet_id = "subnet-0e365d060c45b810b"  
}


resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"  # 테이블 이름
  billing_mode   = "PAY_PER_REQUEST"  # 사용한 만큼만 요금 청구
  hash_key       = "LockID"  # 기본 키

  attribute {
    name = "LockID"  # 속성 이름
    type = "S"       # 문자열 타입
  }
}