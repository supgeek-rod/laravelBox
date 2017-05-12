FROM daocloud.io/ubuntu
MAINTAINER Rod <rod@protobia.tech>

##
## APT 自动安装 PHP 相关的依赖包,如需其他依赖包在此添加
RUN apt-get update \
    && apt-get install -y \
        libmcrypt-dev \
        libz-dev


##
## Volume & Expose
EXPOSE 80
VOLUME /var/www
VOLUME /usr/local/etc/php
VOLUME /etc/apache2
