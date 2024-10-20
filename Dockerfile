# 자바 베이스 이미지 선언
FROM openjdk:17-jdk-slim

# 포트 명시적 선언
EXPOSE 8080

# 작업 디렉토리
WORKDIR /app

# 호스트에서 해당 작업 공간으로 파일 가져오기
COPY ./*.jar /app/test.jar

# 실행 명령어
ENTRYPOINT ["java", "-jar", "/app/test.jar"]
