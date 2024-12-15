# 1단계: 빌드 스테이지
FROM openjdk:17-jdk-slim AS build

RUN apt-get update
RUN apt-get install -y git

WORKDIR /app
# 소스 코드 가져오기
RUN git clone -b develop https://github.com/Trade-Ham/Trade-Ham
WORKDIR /app/Trade-Ham

RUN chmod +x gradlew
RUN ./gradlew clean build -x test

# 2단계: 실행 스테이지
FROM openjdk:17-jdk-slim

# 애플리케이션 포트 노출
EXPOSE 8080
WORKDIR /app

# 빌드 결과물(JAR) 복사
COPY --from=build /app/Trade-Ham/build/libs/tradeham-api-0.0.1.jar /app/app.jar

ENTRYPOINT ["java", "-jar", "/app/app.jar", "--spring.config.location=file:/app/application.properties"]
