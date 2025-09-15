# Terraform 설정 블록
# 프로젝트의 기본 설정과 필요한 프로바이더를 정의합니다
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # AWS 프로바이더 소스 (HashiCorp에서 제공)
      version = "5.11.0"         # 사용할 AWS 프로바이더 버전
    }
  }
}

# AWS 프로바이더 설정
# Terraform이 AWS 서비스와 통신할 수 있게 해주는 플러그인입니다
provider "aws" {
  # 설정 옵션
  region = "ap-northeast-2"  # AWS 리전 설정 (미국 동부 1)
}