# Terraform 설정 파일 - 프로바이더 버전 및 요구사항 정의
# 이 파일은 Terraform이 사용할 프로바이더들의 버전을 명시합니다.

terraform {
  # Terraform 자체의 최소 버전 요구사항 (0.12 이상)
  required_version = ">= 0.13"
  
  # 필요한 프로바이더들을 정의
  required_providers {
    # 랜덤 문자열 생성을 위한 프로바이더 (클러스터 이름에 고유 접미사 생성)
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
    
    # Kubernetes 리소스 관리를 위한 프로바이더 (EKS 클러스터와 상호작용)
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.7.1"
    }
    
    # AWS 리소스 관리를 위한 메인 프로바이더 (VPC, EKS, 보안그룹 등)
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    
    # 로컬 파일 시스템 작업을 위한 프로바이더
    local = {
      source = "hashicorp/local"
      version = "2.5.3"
    }
    
    # null 리소스 생성을 위한 프로바이더 (의존성 관리용)
    null = {
      source = "hashicorp/null"
      version = "3.2.4"
    }
    
    # cloud-init 스크립트 생성을 위한 프로바이더 (EC2 인스턴스 초기화용)
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.3.7"
    }
    
    # Helm 차트 관리를 위한 프로바이더
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}
