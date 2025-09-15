# EKS 클러스터 구성 파일
# 이 파일은 Amazon EKS 클러스터와 워커 노드 그룹을 생성합니다.

# EKS 클러스터 모듈 생성
# terraform-aws-modules/eks/aws 모듈을 사용하여 완전한 EKS 클러스터를 구성
module "eks" {
  source          = "terraform-aws-modules/eks/aws"  # 공식 AWS EKS 모듈 사용
  version = "~> 21.0"

  # 클러스터 기본 설정
  name            = local.cluster_name               # vpc.tf에서 정의된 클러스터 이름 사용
  kubernetes_version = var.kubernetes_version           # variables.tf에서 정의된 Kubernetes 버전
  
  # 서브넷 설정
  # EKS 클러스터가 사용할 프라이빗 서브넷들을 지정
  subnet_ids      = module.vpc.private_subnets       # vpc.tf에서 생성된 프라이빗 서브넷들

  # IAM 역할 서비스 계정(IRSA) 활성화
  # Pod가 AWS 서비스에 접근할 때 IAM 역할을 사용할 수 있도록 설정
  enable_irsa = true

  # 클러스터 태그 설정
  tags = {
    cluster = "terraform-cindy"  # 클러스터 식별용 태그
  }

  # VPC 설정
  vpc_id = module.vpc.vpc_id  # vpc.tf에서 생성된 VPC의 ID

  # EKS 관리형 노드 그룹 기본 설정
  # 모든 노드 그룹에 공통으로 적용될 설정들을 정의
  eks_managed_node_groups = {
    efa = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]

      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
      vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]  # security-groups.tf에서 생성된 보안그룹
    }

    node_group = {
      min_size     = 2  # 최소 노드 수 (2개)
      max_size     = 6  # 최대 노드 수 (6개)
      desired_size = 2  # 원하는 노드 수 (2개)
    }
  }

}

