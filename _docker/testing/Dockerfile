# Testing PHP-FPM image
# Extends dev with Chromium for browser testing (Panther, Selenium, etc.)
ARG DEV_IMAGE=php-fpm-dev:latest
FROM ${DEV_IMAGE}

LABEL maintainer="Pawel Miroslawski <pmiroslawski@gmail.com>"

# Install Chromium and ChromeDriver
# Note: chromium package includes driver on Debian, works on both amd64 and arm64
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    chromium-driver \
    # Dependencies for headless Chrome
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set environment variables for Panther
ENV PANTHER_NO_SANDBOX=1
ENV PANTHER_CHROME_DRIVER_BINARY=/usr/bin/chromedriver
ENV PANTHER_CHROME_BINARY=/usr/bin/chromium

CMD ["php-fpm", "-F"]
