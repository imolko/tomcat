FROM golang:1.12-alpine AS build-mongo-tool

# Branch de mongo tool
ENV MONGOTOOL_VERSION=v3.0
# Package option para establecer version y git hash
ENV VERSION_PACKAGE=github.com/mongodb/mongo-tools/common/options

# clonamos el repositoio.
RUN cd / && \
	apk --no-cache --update add openssl bash && \
	apk --update add --virtual build-dependencies build-base gcc wget git openssl-dev pkgconfig && \
	git clone -b "${MONGOTOOL_VERSION}" --depth 1 "https://github.com/mongodb/mongo-tools"  && \
  cd /mongo-tools && \
	. ./set_gopath.sh && \
  mkdir -p bin && \
	go build -v \
 		-ldflags "-X ${VERSION_PACKAGE}.VersionStr=$(git describe) -X ${VERSION_PACKAGE}.Gitspec=$(git rev-parse HEAD)" \		
		-o bin/mongoimport \
		mongoimport/main/mongoimport.go && \
	apk del build-dependencies && \
	rm -rf /var/cache/apk/* && \
	bin/mongoimport --version
#		-tags ssl \

RUN ldd /mongo-tools/bin/mongoimport

RUN /mongo-tools/bin/mongoimport --version

# tomcat de alpine
FROM tomcat:8-jre8-alpine

LABEL manteiner="Yohany Flores <yohanyflores@gmail.com>"
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
	&& rm -rf /var/cache/apk/*

COPY --from=build-mongo-tool /mongo-tools/bin/mongoimport /usr/local/bin/
RUN ldd /usr/local/bin/mongoimport && mongoimport --version

# Mongo import version.
RUN mongoimport --version

#Version >= 7.1.4
RUN apk --no-cache --update add unzip \
	&& curl -O http://dl.zeroturnaround.com/jrebel-stable-nosetup.zip \
	&& unzip jrebel-stable-nosetup.zip \
	&& rm -rf jrebel-stable-nosetup.zip \
	&& apk del unzip \
	&& rm -rf /var/cache/apk/*

# Copiamos el certificado.
RUN  curl -o /usr/local/share/ca-certificates/cacert.crt https://imolko-dev.nyc3.digitaloceanspaces.com/certs/certs/ca-dev/cacert.crt \
    && update-ca-certificates \
	&& keytool -list -keystore $JAVA_HOME/lib/security/cacerts -storepass "changeit"
#	&& echo "yes" | keytool -import -trustcacerts \
#		-file /usr/local/share/ca-certificates/cacert.crt \
#		-alias imolkocorp. \
#		-keystore  $JAVA_HOME/jre/lib/security/cacerts \
#		-storepass "changeit"


# Para debug con jrebel
EXPOSE 1043
EXPOSE 8090
