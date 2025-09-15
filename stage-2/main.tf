resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr  # VPC의 IP 주소 범위 (변수에서 가져옴)
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id  # VPC ID 참조
  cidr_block              = "10.0.0.0/24"     # 서브넷의 IP 주소 범위
  availability_zone       = "ap-northeast-2a"      # 가용영역 A
  map_public_ip_on_launch = true              # 인스턴스 시작 시 자동으로 공개 IP 할당
}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id  # VPC ID 참조
  cidr_block              = "10.0.1.0/24"     # 서브넷의 IP 주소 범위
  availability_zone       = "ap-northeast-2b"      # 가용영역 B
  map_public_ip_on_launch = true              # 인스턴스 시작 시 자동으로 공개 IP 할당
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"                    # 모든 트래픽 (인터넷으로)
    gateway_id = aws_internet_gateway.igw.id    # 인터넷 게이트웨이로 라우팅
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id      # 서브넷 1 ID
  route_table_id = aws_route_table.rt.id   # 라우팅 테이블 ID
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id      # 서브넷 2 ID
  route_table_id = aws_route_table.rt.id   # 라우팅 테이블 ID
}

resource "aws_security_group" "web-sg" {
  name   = "web"                    # 보안 그룹 이름
  vpc_id = aws_vpc.myvpc.id        # VPC ID 참조

  # HTTP 트래픽 허용 (포트 80)
  ingress {
    description = "HTTP from VPC"   # 설명
    from_port   = 80               # 시작 포트
    to_port     = 80               # 끝 포트
    protocol    = "tcp"            # 프로토콜
    cidr_blocks = ["0.0.0.0/0"]   # 모든 IP에서 허용
  }
  
  # SSH 트래픽 허용 (포트 22)
  ingress {
    description = "SSH"            # 설명
    from_port   = 22               # 시작 포트
    to_port     = 22               # 끝 포트
    protocol    = "tcp"            # 프로토콜
    cidr_blocks = ["0.0.0.0/0"]   # 모든 IP에서 허용
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0                # 모든 포트
    to_port     = 0                # 모든 포트
    protocol    = "-1"             # 모든 프로토콜
    cidr_blocks = ["0.0.0.0/0"]   # 모든 IP로
  }

  tags = {
    Name = "web-sg"                # 태그
  }
}


# S3 버킷 생성
# 파일을 저장하는 클라우드 스토리지입니다
resource "aws_s3_bucket" "example" {
  bucket = "abhisheksterraform2023project"  # 버킷 이름 (전역적으로 고유해야 함)
}

# 첫 번째 웹 서버 인스턴스 생성
resource "aws_instance" "webserver1" {
  ami                    = "ami-0261755bbcb8c4a84"  # Amazon Machine Image (서버 템플릿)
  instance_type          = "t2.micro"               # 인스턴스 타입 (CPU, 메모리 사양)
  vpc_security_group_ids = [aws_security_group.web-sg.id]  # 보안 그룹 연결
  subnet_id              = aws_subnet.sub1.id       # 서브넷 1에 배치
  user_data              = base64encode(file("userdata.sh"))  # 시작 시 실행할 스크립트
}

# 두 번째 웹 서버 인스턴스 생성
resource "aws_instance" "webserver2" {
  ami                    = "ami-0261755bbcb8c4a84"  # Amazon Machine Image
  instance_type          = "t2.micro"               # 인스턴스 타입
  vpc_security_group_ids = [aws_security_group.web-sg.id]  # 보안 그룹 연결
  subnet_id              = aws_subnet.sub2.id       # 서브넷 2에 배치
  user_data              = base64encode(file("userdata1.sh"))  # 시작 시 실행할 스크립트
}

# Application Load Balancer (ALB) 생성
# 트래픽을 여러 서버에 분산시키는 로드 밸런서입니다
resource "aws_lb" "myalb" {
  name               = "myalb"                    # 로드 밸런서 이름
  internal           = false                      # 외부에서 접근 가능
  load_balancer_type = "application"              # 애플리케이션 로드 밸런서 타입

  security_groups = [aws_security_group.web-sg.id]  # 보안 그룹 연결
  subnets         = [aws_subnet.sub1.id, aws_subnet.sub2.id]  # 두 서브넷에 배치

  tags = {
    Name = "web"  # 태그
  }
}

# 타겟 그룹 생성
# 로드 밸런서가 트래픽을 전달할 대상들을 그룹화합니다
resource "aws_lb_target_group" "tg" {
  name     = "myTG"                # 타겟 그룹 이름
  port     = 80                    # 포트 80 (HTTP)
  protocol = "HTTP"                # HTTP 프로토콜
  vpc_id   = aws_vpc.myvpc.id     # VPC ID 참조

  # 헬스 체크 설정 (서버가 정상인지 확인)
  health_check {
    path = "/"                     # 헬스 체크 경로
    port = "traffic-port"          # 트래픽 포트 사용
  }
}

# 첫 번째 웹 서버를 타겟 그룹에 연결
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn  # 타겟 그룹 ARN
  target_id        = aws_instance.webserver1.id  # 웹 서버 1 ID
  port             = 80                          # 포트 80
}

# 두 번째 웹 서버를 타겟 그룹에 연결
resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn  # 타겟 그룹 ARN
  target_id        = aws_instance.webserver2.id  # 웹 서버 2 ID
  port             = 80                          # 포트 80
}

# 로드 밸런서 리스너 생성
# 특정 포트로 들어오는 트래픽을 처리하는 규칙입니다
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn  # 로드 밸런서 ARN
  port              = 80                 # 포트 80
  protocol          = "HTTP"             # HTTP 프로토콜

  # 기본 액션 (트래픽을 타겟 그룹으로 전달)
  default_action {
    target_group_arn = aws_lb_target_group.tg.arn  # 타겟 그룹 ARN
    type             = "forward"                    # 전달 액션
  }
}

# 로드 밸런서 DNS 이름 출력
# 웹사이트 접속에 사용할 수 있는 URL입니다
output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name  # 로드 밸런서의 DNS 이름
}