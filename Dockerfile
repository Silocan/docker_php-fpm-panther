FROM php:8.2-fpm-alpine

# Chromium and ChromeDriver
ENV PANTHER_NO_SANDBOX 1
# Not mandatory, but recommended
ENV PANTHER_CHROME_ARGUMENTS='--disable-dev-shm-usage'
RUN apk add --no-cache chromium chromium-chromedriver


RUN curl -sSLf \
    -o /usr/local/bin/install-php-extensions \
    https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions

# Firefox and GeckoDriver (optional)
ARG GECKODRIVER_VERSION=0.28.0
RUN apk add --no-cache firefox libzip-dev git zip unzip bash curl; \
    docker-php-ext-install zip
RUN wget -q https://github.com/mozilla/geckodriver/releases/download/v$GECKODRIVER_VERSION/geckodriver-v$GECKODRIVER_VERSION-linux64.tar.gz; \
    tar -zxf geckodriver-v$GECKODRIVER_VERSION-linux64.tar.gz -C /usr/bin; \
    rm geckodriver-v$GECKODRIVER_VERSION-linux64.tar.gz

WORKDIR /var/www

COPY --link docker/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY --link docker/docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN install-php-extensions xdebug intl opcache pdo gd zip bcmath xml mysqli curl calendar pdo_mysql redis mongodb-1.15.1 ldap soap;

ENTRYPOINT ["bash", "/entrypoint.sh"]