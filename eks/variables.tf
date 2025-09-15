# Terraform 변수 정의 파일
# 이 파일은 프로젝트에서 사용할 변수들을 정의합니다.

# Kubernetes 클러스터 버전을 정의하는 변수
# EKS 클러스터의 Kubernetes 버전을 지정합니다.
variable "kubernetes_version" {
  default     = 1.31  # 기본값: Kubernetes 1.31 버전
  description = "kubernetes version"
}

# VPC의 CIDR 블록을 정의하는 변수
# VPC의 IP 주소 범위를 지정합니다 (예: 10.0.0.0/16은 10.0.0.0 ~ 10.0.255.255)
variable "vpc_cidr" {
  default     = "10.0.0.0/16"  # 기본값: 10.0.0.0/16 CIDR 블록
  description = "default CIDR range of the VPC"
}

# AWS 리전을 정의하는 변수
# EKS 클러스터와 관련 리소스들이 생성될 AWS 리전을 지정합니다.
variable "aws_region" {
  default = "ap-northeast-2"  # 기본값: 한국(서울) 리전
  description = "aws region"
}

# 모니터링 활성화 변수
# Prometheus Stack 배포 여부를 결정합니다.
variable "enable_monitoring" {
  default     = false
  description = "Enable Prometheus monitoring stack"
}

# Cert-Manager 활성화 변수
# SSL/TLS 인증서 자동 관리 도구 배포 여부를 결정합니다.
variable "enable_cert_manager" {
  default     = false
  description = "Enable Cert-Manager for SSL/TLS certificate management"
}

