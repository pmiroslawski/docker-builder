# Base PHP-FPM image with common extensions
# Multi-architecture support (amd64/arm64) via official PHP base image
FROM php:8.4-fpm-bookworm

LABEL maintainer="Pawel Miroslawski <pmiroslawski@gmail.com>"

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    libfreetype6-dev \
    libgmp-dev \
    libicu-dev \
    libc-client-dev \
    libkrb5-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    librabbitmq-dev \
    libwebp-dev \
    libzip-dev \
    libxml2-dev \
    libonig-dev \
    openssl \
    pkg-config \
    zlib1g \
    zlib1g-dev \
    libmemcached-dev \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        gd \
        gmp \
        intl \
        mbstring \
        opcache \
        pcntl \
        pdo \
        pdo_mysql \
        mysqli \
        sockets \
        soap \
        xml \
        zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install PECL extensions (imap moved to PECL in PHP 8.4)
RUN pecl channel-update pecl.php.net \
    && PHP_OPENSSL=yes pecl install imap \
    && pecl install amqp apcu excimer igbinary redis \
    && docker-php-ext-enable imap amqp apcu excimer igbinary redis \
    && rm -rf /tmp/pear

# Copy base PHP configuration
COPY _docker/base/config/php.ini /usr/local/etc/php/conf.d/99-custom.ini

CMD ["php-fpm", "-F"]
