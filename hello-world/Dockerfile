FROM composer:2 as composer

FROM php:8.1-alpine

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

WORKDIR /app

COPY composer.json composer.lock ./

RUN composer install -n \
    --no-dev \
    --no-cache \
    --no-ansi \
    --no-autoloader \
    --no-scripts \
    --prefer-dist

COPY . .

RUN composer dump-autoload -n --optimize

CMD ["php", "-S", "0.0.0.0:8000", "-t", "/app/public", "/app/server.php"]