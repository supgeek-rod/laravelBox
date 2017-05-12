FROM php:7-apache
MAINTAINER Rod <rod@protobia.tech>

##
## APT 自动安装 PHP 相关的依赖包,如需其他依赖包在此添加
RUN apt-get update \
    && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libz-dev \

    # 官方 PHP 镜像内置命令，安装 PHP 依赖
    && docker-php-ext-install -j$(nproc) \
        mcrypt \
        mbstring \
        pdo_mysql \
        zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd


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
