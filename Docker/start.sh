#!/bin/sh
if [  -z "${JAVA_OPTS}" ]
then
	JAVA_OPTS="-server -Xmx512M -Xms512M -Xmn375M -XX:+PrintFlagsFinal -XX:+PrintGCDetails -Dfile.encoding=UTF8 -Duser.timezone=GMT+08"
fi
if [ -z "${ENV}" ]
then
    ENV="dev"
fi
java ${JAVA_OPTS} -Denv=$ENV -Dfile.encoding=UTF-8 -jar /app.jar
