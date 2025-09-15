# Terraform 출력값 정의 파일
# 이 파일은 생성된 리소스들의 중요한 정보들을 출력하여 사용자가 쉽게 접근할 수 있도록 합니다.

# EKS 클러스터 ID 출력
# 생성된 EKS 클러스터의 고유 식별자를 출력합니다.
# 이 값은 kubectl 설정이나 다른 도구에서 클러스터를 식별하는 데 사용됩니다.
output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

# EKS 클러스터 엔드포인트 출력
# EKS 컨트롤 플레인에 접근하기 위한 API 서버 엔드포인트를 출력합니다.
# kubectl이나 다른 Kubernetes 클라이언트가 클러스터에 연결할 때 사용됩니다.
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

# 클러스터 보안그룹 ID 출력
# EKS 클러스터 컨트롤 플레인에 연결된 보안그룹의 ID를 출력합니다.
# 네트워크 보안 설정이나 추가 보안그룹 규칙 추가 시 참조용으로 사용됩니다.
output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

# AWS 리전 출력
# EKS 클러스터가 생성된 AWS 리전을 출력합니다.
# AWS CLI 명령어나 다른 AWS 서비스 연동 시 참조용으로 사용됩니다.
output "region" {
  description = "AWS region"
  value       = var.aws_region
}

# OIDC 프로바이더 ARN 출력
# EKS 클러스터의 OIDC(OpenID Connect) 프로바이더 ARN을 출력합니다.
# IRSA(IAM Roles for Service Accounts) 설정이나 외부 인증 시스템 연동 시 사용됩니다.
output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

# 주석 처리된 kubectl 설정 명령어
# EKS 클러스터에 kubectl을 연결하기 위한 AWS CLI 명령어입니다.
# 필요시 주석을 해제하여 사용할 수 있습니다.
#output "zz_update_kubeconfig_command" {
  # value = "aws eks update-kubeconfig --name " + module.eks.cluster_id
#  value = format("%s %s %s %s", "aws eks update-kubeconfig --name", module.eks.cluster_id, "--region", var.aws_region)
#}

# Helm 차트 배포 상태 출력
output "helm_releases" {
  description = "Status of deployed Helm charts"
  value = {
    ingress_nginx = helm_release.ingress_nginx.status
    metrics_server = helm_release.metrics_server.status
    prometheus_stack = var.enable_monitoring ? helm_release.prometheus_stack[0].status : "disabled"
    cert_manager = var.enable_cert_manager ? helm_release.cert_manager[0].status : "disabled"
  }
}

