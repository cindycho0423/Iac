variable "instance_type" {
  description = "EC2 instance type"  # EC2 인스턴스 타입
  type        = string               # 문자열 타입
  default     = "t2.micro"          # 기본값: t2.micro (작은 인스턴스)
}

variable "ami_id" {
  description = "EC2 AMI ID"  # EC2 AMI ID
  type        = string         # 문자열 타입
  default     = "ami-0662f4965dfc70aca" # Ubuntu 20.04 LTS
}

variable "cidr" {
  default = "10.0.0.0/16"  # 기본값: 10.0.0.0부터 10.0.255.255까지 (65,536개 IP 주소)
}

resource "aws_instance" "terraform_test_instance" {
  ami           = var.ami_id      # Amazon Machine Image (서버 템플릿)
  instance_type = var.instance_type  # 인스턴스 타입 (CPU, 메모리 사양)
  tags = {
    Name = "terraform_test_instance"
  }
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.terraform_test_instance.public_ip
}

