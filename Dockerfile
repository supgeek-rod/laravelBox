## 参考 https://github.com/DaoCloud/php-laravel-mysql-sample/blob/master/Dockerfile
FROM php:5.6-apache
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
        git \
        wget \
        vim \

    # 官方 PHP 镜像内置命令，安装 PHP 依赖
    && docker-php-ext-install -j$(nproc) \
        mcrypt \
        mbstring \
        pdo_mysql \
        zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

##
## 安装 node npm 等
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash \
&& apt-get install -y nodejs \
&& npm install -g bower \
&& npm install -g bower-npm-resolver
# && npm install -g cordova ionic


##
## 用完包管理器后安排打扫卫生可以显著的减少镜像大小
RUN apt-get clean \
&& apt-get autoclean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


##
## 设置环境变量
ENV HC_VERSION 2.0.0-beta.1
ENV HC_ENV product


##
## 安装 Composer，此物是 PHP 用来管理依赖关系的工具
RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer


##
## Apache 配置
RUN echo '<Directory /var/www/HeyCommunityCloud>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf

RUN sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/HeyCommunityCloud/g' /etc/apache2/sites-enabled/000-default.conf


##
## 开启 URL 重写模块
## 配置默认放置 App 的目录
RUN a2enmod rewrite \
    && service apache2 restart \
    && mkdir -p /app \
    && ln -s /app /var/www/HeyCommunityCloud


##
## 复制程序代码
WORKDIR /app
COPY . /app
RUN chown -R :www-data . && chmod g+w .


##
## 部署 frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run ionic:build
RUN npm cache clean


##
## 部署 backend
WORKDIR /app/backend
RUN composer install
RUN bower install -F -p --allow-root
RUN cp .env.example .env \
    && php artisan key:g
RUN chown -R :www-data . \
    && chmod -R g+w storage bootstrap/cache public
RUN composer clear-cache


##
##
EXPOSE 80
VOLUME /app/backend/public/uploads
RUN env
ENTRYPOINT ["/bin/bash", "/app/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
