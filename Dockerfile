FROM tomcat:8-jre8

MAINTAINER Yohany Flores <yohanyflores@gmail.com>

LABEL com.imolko.group=imolko
LABEL com.imolko.type=base


ENV JAVA_OPTS "-Djavax.servlet.request.encoding=UTF8 -Dfile.encoding=UTF8 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8090 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.local.only=false"

#configuramos la zona horaria
RUN echo "America/Caracas" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# Necesitamos por los momentos, una version cliente con sus tools de mongo.
#-------------------------------------------

# gpg: key 7F0CEB10: public key "Richard Kreuter <richard@10gen.com>" imported
# RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 492EAFE8CD016A07919F1D2B9ECBEC467F0CEB10
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10


ENV MONGO_MAJOR 3.0
ENV MONGO_VERSION 3.0.14

# Mosca cuando se actualize a la version 3.2+ Es necesario cambiar el repositorio a jessie
RUN echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/$MONGO_MAJOR main" > /etc/apt/sources.list.d/mongodb-org.list

RUN set -x \
	&& apt-get update \
	&& apt-get install -y \
		mongodb-org-tools=$MONGO_VERSION \
		zip \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/lib/mongodb


# Instalamos cliente bash para rabbitmq
RUN set -x && apt-get update && apt-get install -y amqp-tools --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Instalamos jrebel para developer
RUN set -x && curl -O http://dl.zeroturnaround.com/jrebel-stable-nosetup.zip \
	&& unzip jrebel-stable-nosetup.zip \
	&& rm -rf jrebel-stable-nosetup.zip

# Para debug
EXPOSE 1043
EXPOSE 8090

