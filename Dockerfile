FROM daocloud.io/php:5.6-apache
MAINTAINER Rod <rod@protobia.tech>

##
## APT 自动安装 PHP 相关的依赖包,如需其他依赖包在此添加
RUN apt-get update \
    && apt-get install -y \
        libmcrypt-dev \
        libz-dev \

    # 官方 PHP 镜像内置命令，安装 PHP 依赖
    && docker-php-ext-install \
        mcrypt \
        mbstring \
        pdo_mysql \
        zip


##
## 用完包管理器后安排打扫卫生可以显著的减少镜像大小
RUN apt-get clean \
&& apt-get autoclean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


##
## 开启 Apache 重写模块
RUN a2enmod rewrite \
    && service apache2 restart


##
## Volume & Expose
EXPOSE 80
VOLUME /var/www
VOLUME /usr/local/etc/php
VOLUME /etc/apache2
