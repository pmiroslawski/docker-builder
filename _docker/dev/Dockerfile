# Development PHP-FPM image
# Extends base with dev tools: Composer, Git, Node.js, Xdebug
ARG BASE_IMAGE=php-fpm-base:latest
FROM ${BASE_IMAGE}

LABEL maintainer="Pawel Miroslawski <pmiroslawski@gmail.com>"

# Install development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-flow \
    vim \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && rm -rf /tmp/pear

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer --version

# Install Node.js (LTS)
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy development PHP configuration
COPY _docker/dev/config/php.ini /usr/local/etc/php/conf.d/99-dev.ini
COPY _docker/dev/config/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

CMD ["php-fpm", "-F"]
