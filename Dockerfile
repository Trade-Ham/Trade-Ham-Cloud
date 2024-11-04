# 1단계: 빌드 스테이지
FROM openjdk:21-jdk-slim AS build # 자바 버젼 다르다면 바꾸기

RUN apt-get update 
RUN apt-get install -y git

WORKDIR /app
RUN git clone -b dev https://github.com/KTB-FarmMate/FramMate-API-Server # 해당 깃허브 링크로 바꾸기
WORKDIR /app/FramMate-API-Server

RUN chmod +x gradlew
RUN ./gradlew clean build -x test # 빌드 방식 다르다면 바꾸기

# 2단계: 실행 스테이지
FROM openjdk:21-jdk-slim

# 포트 명시적 선언
EXPOSE 8080

# 환경 변수 정의
ARG MYSQL_HOST
ARG MYSQL_PORT
ARG DB_NAME
ARG MYSQL_USERNAME
ARG MYSQL_PASSWORD

ENV MYSQL_HOST=${MYSQL_HOST}
ENV MYSQL_PORT=${MYSQL_PORT}
ENV DB_NAME=${DB_NAME}
ENV MYSQL_USERNAME=${MYSQL_USERNAME}
ENV MYSQL_PASSWORD=${MYSQL_PASSWORD}

WORKDIR /app
COPY --from=build /app/FramMate-API-Server/build/libs/farmmate-0.0.1-SNAPSHOT.jar /app/app.jar # 생성되는 .jar파일명 다르다면 바꾸기

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
