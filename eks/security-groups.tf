# 보안 그룹 생성
resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id
}

# 인그레스 규칙
resource "aws_vpc_security_group_ingress_rule" "all_worker_mgmt_ingress" {
  description       = "allow inbound traffic from eks"
  security_group_id = aws_security_group.all_worker_mgmt.id
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

# 이그레스 규칙
resource "aws_vpc_security_group_egress_rule" "all_worker_mgmt_egress" {
  description       = "allow outbound traffic to anywhere"
  security_group_id = aws_security_group.all_worker_mgmt.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}