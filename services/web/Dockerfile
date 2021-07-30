#
# Build stage
#
FROM maven:3.6.0-jdk-11-slim AS build
COPY src /app/build/src
COPY pom.xml /app/build
RUN mvn -f /app/build/pom.xml clean package

#
# Package stage
#
FROM openjdk:11-jre-slim


RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		curl \
	; \
	rm -rf /var/lib/apt/lists/*

COPY --from=build /app/build/target/spring-boot*.jar /app/app.jar
EXPOSE 80
ENTRYPOINT ["java","-jar","/app/app.jar"]
