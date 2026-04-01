FROM composer:2 AS composer_deps

WORKDIR /app

COPY laravel-app/composer.json laravel-app/composer.lock ./

RUN composer install \
    --no-dev \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --ignore-platform-req=ext-intl \
    --prefer-dist \
    --optimize-autoloader

FROM node:22-alpine AS frontend

WORKDIR /app

COPY laravel-app/package.json ./

RUN npm install

COPY laravel-app/resources ./resources
COPY laravel-app/public ./public
COPY laravel-app/vite.config.js ./

RUN npm run build

FROM php:8.4-fpm-alpine AS app

WORKDIR /var/www/html

RUN apk add --no-cache \
        fcgi \
        icu-dev \
        libpng-dev \
        libzip-dev \
        mariadb-client \
        oniguruma-dev \
        unzip \
        zip \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
        bcmath \
        exif \
        gd \
        intl \
        pdo_mysql \
        zip \
    && rm -rf /var/cache/apk/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY laravel-app /var/www/html
COPY --from=composer_deps /app/vendor /var/www/html/vendor
COPY --from=frontend /app/public/build /var/www/html/public/build
COPY docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache \
    && chown -R www-data:www-data /var/www/html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]

FROM nginx:1.29-alpine AS web

WORKDIR /var/www/html

COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY laravel-app/public /var/www/html/public
COPY --from=frontend /app/public/build /var/www/html/public/build

RUN mkdir -p /var/www/html/storage/app \
    && ln -s /var/www/html/storage/app/public /var/www/html/public/storage
