# VPC 및 네트워킹 인프라 구성 파일
# 이 파일은 EKS 클러스터를 위한 VPC, 서브넷, NAT 게이트웨이 등을 생성합니다.

# AWS 프로바이더 설정
# variables.tf에서 정의된 aws_region 변수를 사용하여 AWS 리전을 지정
provider "aws" {
  region = var.aws_region
}

# 사용 가능한 가용영역(Availability Zones) 데이터 소스
# 현재 리전에서 사용 가능한 모든 가용영역을 가져옵니다.
data "aws_availability_zones" "available" {}

# 로컬 변수 정의
# 클러스터 이름을 동적으로 생성하기 위한 로컬 변수
locals {
  # 클러스터 이름: "terraform-cindy-eks-" + 랜덤 문자열 (예: terraform-cindy-eks-a1b2c3d4)
  cluster_name = "terraform-cindy-eks-${random_string.suffix.result}"
}

# 랜덤 문자열 리소스
# 클러스터 이름에 사용할 고유한 8자리 랜덤 문자열을 생성
resource "random_string" "suffix" {
  length  = 8  # 8자리 문자열 생성
  special = false  # 특수문자 제외
}

# VPC 모듈 생성
# terraform-aws-modules/vpc/aws 모듈을 사용하여 완전한 VPC 인프라를 구성
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"  # 공식 AWS VPC 모듈 사용
  version = "~> 6.0"  # 모듈 버전 지정

  # VPC 기본 설정
  name                 = "terraform-cindy-eks-vpc"  # VPC 이름
  cidr                 = var.vpc_cidr    # VPC CIDR 블록 (10.0.0.0/16)
  azs                  = data.aws_availability_zones.available.names  # 사용 가능한 모든 가용영역 사용
  
  # 프라이빗 서브넷 설정 (워커 노드용)
  # 각 가용영역에 프라이빗 서브넷 생성
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  
  # 퍼블릭 서브넷 설정 (로드밸런서, NAT 게이트웨이용)
  # 각 가용영역에 퍼블릭 서브넷 생성
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24"]
  
  # NAT 게이트웨이 설정
  enable_nat_gateway   = true   # NAT 게이트웨이 활성화 (프라이빗 서브넷에서 인터넷 접근용)
  single_nat_gateway   = true   # 단일 NAT 게이트웨이 사용 (비용 절약)
  
  # DNS 설정
  enable_dns_hostnames = true   # DNS 호스트네임 활성화
  enable_dns_support   = true   # DNS 지원 활성화

  # VPC 태그 설정
  # EKS 클러스터가 이 VPC를 사용할 수 있도록 태그 설정
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  # 퍼블릭 서브넷 태그 설정
  # EKS가 퍼블릭 로드밸런서를 생성할 수 있도록 태그 설정
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"  # External Load Balancer용
  }

  # 프라이빗 서브넷 태그 설정
  # EKS가 내부 로드밸런서를 생성할 수 있도록 태그 설정
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"  # Internal Load Balancer용
  }
}
