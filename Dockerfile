FROM drupal:latest
MAINTAINER r2h2 <rainer@hoerbe.at>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get install -y mariadb-client net-tools vim wget \
 && apt-get clean
 
WORKDIR /var/www/html/modules/ 
ENV SSP_VERSION=simplesamlphp_auth-8.x-3.0-alpha4.tar.gz
RUN wget https://ftp.drupal.org/files/projects/$SSP_VERSION
RUN tar -xzf $SSP_VERSION \
 && mv simplesamlphp_auth-8.x-3.0-* simplesamlphp_auth-8.x-3.0 \
 && chown 33 *
 
WORKDIR /var/www/html/