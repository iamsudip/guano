FROM hypertrace/java:11

RUN mkdir -p /opt/guano

COPY target/guano-0.1.0.jar /opt/guano/guano-0.1.0.jar

ENTRYPOINT ["java", "-jar", "/opt/guano/guano-0.1.0.jar"]
