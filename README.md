# Trade-Ham-Cloud
---
# EC2에 실제 서비스 배포해보기

준비물
- EC2 인스턴스
	- .pem 파일(ec2 접속키)
- 프리티어 RDS
- .jar 파일


### 0. EC2 생성하기
- [인스턴스 생성 방법](https://sz-tech.tistory.com/entry/AWS-2-EC2-%EC%9D%B8%EC%8A%A4%ED%84%B4%EC%8A%A4-%EC%83%9D%EC%84%B1%ED%95%98%EA%B3%A0-%EC%97%B0%EA%B2%B0%ED%95%98%EA%B8%B0)
- Amazon Linux로 설치하기 - 이걸로 진행할거임
- 생성된 인스턴스에서 보안그룹에 8080 추가해주기
- **생성된 인스턴스 퍼블릭 IP 적어두기**
### 1. RDS 생성
 - AWS 접속
 - 서비스 검색 - RDS
 - 데이터 베이스 생성하기
	 1. 데이터베이스 생성 방식 선택 - 표준 생성
	 2. 엔진 옵션 - MySQL
	 3. 엔진 버전 - MySQL 8.0.32 (다른 방법은 작동)
	 4. 템플릿 - 프리티어
	 5. 설정
		 - DB 인스턴스 식별자 - <원하는이름(이게 RDS 베이스 주소가 됨)>
		 - 자격 증명 설정
			 - 마스터 사용자 이름 - <원하는거 ID>
			 - 자격 증명 관리 - 자체 관리
			 - 마스터 암호 - <원하는 Password>
			 - 마스터 암호 확인 - <원하는 Password>
	6. 인스턴스 구성 - 설정x
	7. 스토리지 - 설정x
	8. 연결
		- 컴퓨팅 리소스 - 리소스 연결 안함
		- 네트워크 유형 - IPv4 (그대로)
		- Virtual Private Cloud(VPC) - Default(그대로)
		- DB 서브넷 그룹 - Default(그대로)
		- 퍼블릭 액세스 - 예
		- VPC 보안 그룹(방화벽) - 새로 생성 - 이름 아무거나
		- 가용영역 - 기본 설정 없음
	9. 데이터베이스 인증 - 암호 인증(그대로)
	10. 데이터베이스 생성 버튼 눌러 바로 생성하기
- **데이터 베이스 생성되면 엔드포인트 복사해두기**
- 접속 테스트(택 1)
	- MySQLWorkbench를 통해 접속 테스트
	- `mysql -h <rds-endpoint> -P <port> -u <username>`
	- 접속 잘 된다면 정상적으로 생성되고 접속을 확인함
### 2. .jar 파일 생성
- 기존 소스코드에서 데이터베이스 URL을 RDS Endpoint 주소로 고치기
- `gradlew build` 로 빌드
- 빌드된 파일명과 절대경로 적어두기

### 3.  EC2에 .jar 파일 보내기
- 터미널에서 .pem키가 있는 곳(ec2 접속키, 보통 Downloads에 있음)로 이동
- `chmod 400 <.pem>` : 접속키 권한 변경, 이미 했다면 안해도 됨
- `scp -i <sshkey.pem> <빌드한 .jar 파일 경로> ec2-user@<생성한 인스턴스 퍼블릭 IP>:~/test.jar` : 방금 빌드한 jar 파일을 EC2 서버로 전송

### 4. EC2에 접속하고 도커 설치
1. EC2 접속
	- `ssh -i <sshkey.pem> ec2-user@<생성한 인스턴스 퍼블릭 IP>`
2. Docker 설치
	- Amazon Linux는 CentOS 기반이므로 명령어는 다 `yum`
	- `sudo yum update -y`
	- `sudo yum install -y docker`
	- `sudo systemctl start docker`
	- `sudo systemctl enable docker`
	- `sudo yum install git -y`
	- `sudo docker` 를 쳤을때 이것저것 나오면 정상
3. 도커 파일 생성하기
	- `sudo vi Dockerfile` 하고 깃허브 Dockerfile 내용 참고
4. 도커 이미지 빌드하기
```
folder
├── Dockerfile
└── test.jar
```
이 형태에서 시작
- `sudo docker build -t <이미지명>:<태그명> .`
- 이미지 빌드가 다 되었다면 `sudo docker images` 로 생성한 이미지를 확인
5. 도커 컨테이너 실행하기
	- `sudo docker run -d -p 8080:8080 --name <원하는 컨테이너명> <이미지명>:<태그명>`
	- 정상적으로 실행했다면 `sudo docker ps` 를 했을때 실행중인 컨테이너가 보일 것임
	- 안보인다면?
		- `sudo docker ps -a`를 해서 꺼져있는 컨테이너 ID를 확인하고
		- `sudo docker logs <컨테이너 ID>`로 문제를 확인
6. 애플리케이션에 요청 날려보기
	- `<퍼블릭 주소 IP>:8080` 주소 형태로 요청 날리면 될것임

