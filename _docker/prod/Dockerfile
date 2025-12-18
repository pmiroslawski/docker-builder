# Production PHP-FPM image
# Extends base with production optimizations
ARG BASE_IMAGE=php-fpm-base:latest
FROM ${BASE_IMAGE}

LABEL maintainer="Pawel Miroslawski <pmiroslawski@gmail.com>"

# Copy production PHP configuration
COPY _docker/prod/config/php.ini /usr/local/etc/php/conf.d/99-prod.ini

# Security: remove unnecessary packages and files
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /usr/local/etc/php/php.ini-development

CMD ["php-fpm", "-F"]
