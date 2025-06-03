FROM openjdk:17
COPY target/spring-boot-hello-world-*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]

