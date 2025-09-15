  # instance_type = "t2.micro" 
  # ami = "ami-0662f4965dfc70aca" 
  # subnet_id = "subnet-0e365d060c45b810b"  

provider "aws" {
  region = "ap-northeast-2" 
}


resource "aws_vpc" "terra-stage5-vpc" {
  cidr_block = var.cidr  # VPC의 IP 주소 범위
}

resource "aws_subnet" "terra5-sub1" {
  vpc_id                  = aws_vpc.terra-stage5-vpc.id  # VPC ID 참조
  cidr_block              = "10.0.0.0/28"     # 서브넷의 IP 주소 범위
  availability_zone       = "ap-northeast-2a"      # 가용영역 A
  map_public_ip_on_launch = true              # 인스턴스 시작 시 자동으로 공개 IP 할당
}

resource "aws_internet_gateway" "terra5-igw" {
  vpc_id = aws_vpc.terra-stage5-vpc.id  # VPC ID 참조
}

resource "aws_route_table" "terra5-rt" {
  vpc_id = aws_vpc.terra-stage5-vpc.id  # VPC ID 참조

  route {
    cidr_block = "0.0.0.0/0"                    # 모든 트래픽 (인터넷으로)
    gateway_id = aws_internet_gateway.terra5-igw.id    # 인터넷 게이트웨이로 라우팅
  }
}

resource "aws_route_table_association" "terra5-rt-association" {
  subnet_id      = aws_subnet.terra5-sub1.id      # 서브넷 ID
  route_table_id = aws_route_table.terra5-rt.id   # 라우팅 테이블 ID
}

resource "aws_security_group" "terra5-sg" {
  name   = "terra5-sg"                    # 보안 그룹 이름
  vpc_id = aws_vpc.terra-stage5-vpc.id        # VPC ID 참조

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
    Name = "terra5-sg"                # 태그
  }
}

# EC2 인스턴스 생성 (프로비저너 포함)
# AWS의 가상 서버를 생성하고 추가 설정을 자동화합니다
resource "aws_instance" "terra5-ec2" {
  ami                    = "ami-0662f4965dfc70aca"  # Amazon Machine Image (서버 템플릿)
  instance_type          = "t2.micro"               # 인스턴스 타입 (CPU, 메모리 사양)
  key_name               = "terra5-key"  # SSH 키 페어 연결
  vpc_security_group_ids = [aws_security_group.terra5-sg.id]  # 보안 그룹 연결
  subnet_id              = aws_subnet.terra5-sub1.id       # 서브넷에 배치

  # SSH 연결 설정
  connection {
    type        = "ssh"            # SSH 연결 타입
    user        = "ubuntu"         # EC2 인스턴스의 사용자명으로 변경하세요
    private_key = file("~/.ssh/terra5-key.pem")  # 개인 키 파일 경로로 변경하세요
    host        = self.public_ip   # 인스턴스의 공개 IP
  }

  # 파일 프로비저너 (로컬 파일을 원격 서버로 복사)
  provisioner "file" {
    source      = "app.py"                           # 로컬 파일 경로로 변경하세요
    destination = "/home/ubuntu/app.py"              # 원격 서버의 파일 경로로 변경하세요
  }

  # 원격 실행 프로비저너 (원격 서버에서 명령어 실행)
  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",       # 원격 인스턴스에서 메시지 출력
      "sudo apt update -y",                          # 패키지 목록 업데이트 (Ubuntu용)
      "sudo apt-get install -y python3-pip",        # Python pip 설치 예제
      "cd /home/ubuntu",                             # 디렉토리 변경
      "sudo pip3 install flask",                     # Flask 웹 프레임워크 설치
      "sudo python3 app.py &",                       # Flask 앱을 백그라운드에서 실행
    ]
  }
}


