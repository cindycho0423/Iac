#!/bin/bash
# 웹 서버 설정 스크립트 (두 번째 서버용)
# 이 스크립트는 EC2 인스턴스가 시작될 때 자동으로 실행됩니다

# 패키지 목록 업데이트
apt update

# Apache 웹 서버 설치
apt install -y apache2

# 인스턴스 메타데이터를 사용하여 인스턴스 ID 가져오기
# AWS의 내부 메타데이터 서비스에서 인스턴스 정보를 가져옵니다
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# AWS CLI 설치 (S3에서 파일을 다운로드하기 위해)
apt install -y awscli

# S3 버킷에서 이미지 다운로드 (현재 주석 처리됨)
# aws s3 cp s3://myterraformprojectbucket2023/project.webp /var/www/html/project.png --acl public-read

# 포트폴리오 내용과 이미지를 포함한 간단한 HTML 파일 생성
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>My Portfolio</title>
  <style>
    /* 텍스트에 애니메이션과 스타일 추가 */
    @keyframes colorChange {
      0% { color: red; }    /* 빨간색에서 시작 */
      50% { color: green; } /* 중간에 초록색 */
      100% { color: blue; } /* 끝에 파란색 */
    }
    h1 {
      animation: colorChange 2s infinite;  /* 2초마다 색상 변경 반복 */
    }
  </style>
</head>
<body>
  <h1>Terraform Project Server 1</h1>
  <h2>Instance ID: <span style="color:green">$INSTANCE_ID</span></h2>
  <p>Welcome to CloudChamp's Channel</p>
  
</body>
</html>
EOF

# Apache 웹 서버 시작 및 부팅 시 자동 시작 설정
systemctl start apache2    # Apache 서비스 시작
systemctl enable apache2   # 시스템 부팅 시 자동으로 Apache 시작