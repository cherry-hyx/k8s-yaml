FROM reg.ccc.io/library/openjdk:8-jre-alpine
VOLUME /tmp
ADD ./target/service-manage.jar /app/service-manage.jar
ADD start.sh  /app/start.sh
RUN chmod u+x /app/start.sh
WORKDIR /app
EXPOSE 8080
ENTRYPOINT ["/bin/sh","/start.sh"]