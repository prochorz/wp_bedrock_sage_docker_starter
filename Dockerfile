FROM php:8.1-apache AS builder

RUN a2enmod rewrite headers
RUN apt-get update
RUN apt-get install -y \
    wget \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    libfreetype6-dev \
    libmagickwand-dev \
    sendmail

RUN docker-php-ext-configure gd \
    --with-webp=/usr/include/ \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ \
    && docker-php-ext-install mysqli exif zip gd \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && sed -i 's|www/html|www/html/web|' /etc/apache2/sites-enabled/000-default.conf \
    && a2enmod rewrite \
    && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && sed -i 's|upload_max_filesize = 2M|upload_max_filesize = 10M|' /usr/local/etc/php/php.ini \
    && sed -i 's|;sendmail_path =|sendmail_path = "/usr/sbin/sendmail -t -i"|' /usr/local/etc/php/php.ini \
    && rm -r /var/lib/apt/lists/*

RUN cd /usr/local/bin \
    && curl -sS https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o wp \
    && chmod +x ./wp

#RUN curl -s -o /usr/local/bin/wp \
#    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
#    && chmod +x /usr/local/bin/wp \
#    && usermod --non-unique --uid 1000 www-data

FROM composer:2.2 AS composer-bedrock

COPY ./bedrock/plugins /var/www/html/plugins
COPY ./bedrock/composer.json /var/www/html/
RUN cd /var/www/html/ && composer install --no-scripts

FROM composer:2.2 AS composer-sage

COPY ./bedrock/web/app/themes/sage/composer.json /var/www/html/web/app/themes/sage/
RUN cd /var/www/html/web/app/themes/sage && composer install

FROM builder

RUN a2enmod rewrite

WORKDIR /var/www/html

COPY ./bedrock ./
COPY --from=composer-bedrock /var/www/html/vendor ./vendor
COPY --from=composer-bedrock /var/www/html/web/wp ./web/wp
COPY --from=composer-bedrock /var/www/html/web/app/plugins ./web/app/plugins
COPY --from=composer-bedrock /var/www/html/web/app/mu-plugins ./web/app/mu-plugins
COPY --from=composer-sage /var/www/html/web/app/themes/vendor ./web/app/themes/vendor

RUN usermod -u 501 www-data && chown -R 501:33 ./web/app/