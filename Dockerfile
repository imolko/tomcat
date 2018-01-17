# tomcat de alpine
FROM tomcat:8-jre8-alpine

MAINTAINER Yohany Flores <yohanyflores@gmail.com>

LABEL com.imolko.group=imolko
LABEL com.imolko.type=base

ARG TZ=America/Caracas
ENV TZ ${TZ}

RUN apk --no-cache --update add tzdata \
    && cp "/usr/share/zoneinfo/${TZ}" /etc/localtime \
	&& echo "${TZ}" >  /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*
	

ENV JAVA_OPTS "-Djavax.servlet.request.encoding=UTF8 -Dfile.encoding=UTF8 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8090 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.local.only=false"

ARG TZ=America/Caracas
ENV TZ ${TZ}

RUN apk --no-cache --update add tzdata \
    && cp "/usr/share/zoneinfo/${TZ}" /etc/localtime \
	&& echo "${TZ}" >  /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*

RUN apk --no-cache --update add \
		ca-certificates \
    	curl \
		mongodb-tools \
	&& rm -rf /var/cache/apk/*

#Version >= 7.1.4
RUN apk --no-cache --update add unzip \
	&& curl -O http://dl.zeroturnaround.com/jrebel-stable-nosetup.zip \
	&& unzip jrebel-stable-nosetup.zip \
	&& rm -rf jrebel-stable-nosetup.zip \
	&& apk del tzdata \
	&& rm -rf /var/cache/apk/*

# Copiamos el certificado.
RUN  curl -o /usr/local/share/ca-certificates/cacert.crt https://imolko-dev.nyc3.digitaloceanspaces.com/certs/certs/ca-dev/cacert.crt \
    && update-ca-certificates \
	&& echo "yes" | keytool -import -trustcacerts \
		-file /usr/local/share/ca-certificates/cacert.crt \
		-alias imolkocorp. \
		-keystore  $JAVA_HOME/jre/lib/security/cacerts \
		-storepass "changeit"


# Para debug
EXPOSE 1043
EXPOSE 8090

