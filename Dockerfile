FROM golang:1.11-stretch AS build-mongo-tool

# Branch de mongo tool
ENV MONGOTOOL_VERSION=v3.0
# Package option para establecer version y git hash
ENV VERSION_PACKAGE=github.com/mongodb/mongo-tools/common/options

# clonamos el repositoio.
RUN cd / && \
	git clone -b "${MONGOTOOL_VERSION}" --depth 1 "https://github.com/mongodb/mongo-tools" && \
	cd /mongo-tools && \
	. ./set_gopath.sh && \
	mkdir -p bin && \
	go build -v \
 		-ldflags "-X ${VERSION_PACKAGE}.VersionStr=$(git describe) -X ${VERSION_PACKAGE}.Gitspec=$(git rev-parse HEAD)" \		
		-o bin/mongoimport \
		mongoimport/main/mongoimport.go && \
	bin/mongoimport --version

# Creamso tomcat repository.
FROM tomcat:8-jre8

LABEL maintainer="Yohany Flores <yohanyflores@gmail.com>"
LABEL com.imolko.group=imolko
LABEL com.imolko.type=base

# JAVA_OPTS
ENV JAVA_OPTS "-Djavax.servlet.request.encoding=UTF8 -Dfile.encoding=UTF8 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8090 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.local.only=false"

#configuramos la zona horaria
RUN echo "America/Caracas" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# copiamos la version compilada previamente de mongo import.
COPY --from=build-mongo-tool /mongo-tools/bin/mongoimport /usr/local/bin/
RUN ldd /usr/local/bin/mongoimport && mongoimport --version

# Instalamos jrebel para developer
RUN set -x && curl -O http://dl.zeroturnaround.com/jrebel-stable-nosetup.zip \
	&& unzip jrebel-stable-nosetup.zip \
	&& rm -rf jrebel-stable-nosetup.zip

RUN  curl -o /usr/local/share/ca-certificates/cacert.crt https://imolko-dev.nyc3.digitaloceanspaces.com/certs/certs/ca-dev/cacert.crt \
    && update-ca-certificates \
	&& keytool -list -keystore $JAVA_HOME/lib/security/cacerts -storepass "changeit"

# Para debug
EXPOSE 1043
EXPOSE 8090

