FROM openjdk:17
COPY COPY app.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]

