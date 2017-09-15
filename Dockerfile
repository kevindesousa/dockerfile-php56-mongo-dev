FROM php:5.6-fpm

RUN apt-get update \
  && apt-get install -y imagemagick libmagickwand-dev libmagickcore-dev \
  && apt-get install -y libmcrypt-dev libcurl4-gnutls-dev libicu-dev libxslt-dev libssl-dev

RUN apt-get install zlib1g-dev

RUN docker-php-ext-install -j$(nproc) exif iconv mcrypt mysqli pdo_mysql zip curl bcmath opcache \
  && docker-php-ext-install -j$(nproc) json intl session xmlrpc xsl \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd

# install mongo
RUN  pecl install mongodb \
  && pecl install mongo \
  && docker-php-ext-enable mongo mongodb

# install xdebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
RUN echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Disable Populating Raw POST Data
# Not needed when moving to PHP 7.
# http://php.net/manual/en/ini.core.php#ini.always-populate-raw-post-data
RUN echo "always_populate_raw_post_data=-1" > $PHP_INI_DIR/conf.d/always_populate_raw_post_data.ini

# install memcached
RUN apt-get update \
    && apt-get install -y zlib1g-dev libmemcached11 libmemcached-dev \
    && yes '' | pecl install memcached-2.2.0 \
    && docker-php-ext-enable memcached \
    && yes '' | pecl install memcache \
    && docker-php-ext-enable memcache

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

# Set timezone
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/UTC /etc/localtime
RUN "date"

COPY php.ini /usr/local/etc/php/

# install phpunit
RUN curl https://phar.phpunit.de/phpunit-5.7.phar -L > phpunit.phar \
  && chmod +x phpunit.phar \
  && mv phpunit.phar /usr/local/bin/phpunit \
  && phpunit --version


WORKDIR /var/www/app
