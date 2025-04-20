FROM alpine:3.21.3 AS base

ENV MEDIAWIKI_MAJOR_VERSION=1.43
ENV MEDIAWIKI_VERSION=1.43.1
ENV COMPOSER_ROOT_VERSION=${MEDIAWIKI_VERSION}

LABEL Maintainer="lis <hello@lis.sh>"
LABEL Description="Base image for Mediawiki 1.43.1 with PHP-FPM 8.3 (Alpine 3.21.3)"

WORKDIR /var/www/html

# install runtime packages
RUN apk add --no-cache \
  curl \
  imagemagick \
  lua5.1 \
  libthai-dev \
  php83 \
  php83-calendar \
  php83-ctype \
  php83-curl \
  php83-exif \
  php83-fileinfo \
  php83-fpm \
  php83-gd \
  php83-iconv \
  php83-intl \
  php83-json \
  php83-mbstring \
  php83-mysqli \
  php83-opcache \
  php83-openssl \
  php83-pcntl \
  php83-pecl-luasandbox \
  php83-pecl-redis \
  php83-pear \
  php83-phar \
  php83-posix \
  php83-session \
  php83-simplexml \
  php83-sodium \
  php83-tokenizer \
  php83-xml \
  php83-xmlreader \
  php83-xmlwriter \
  php83-zlib \
  python3 \
  supervisor \
  unzip \
  vips-tools

# copy runtime configs
COPY config/php/fpm-pool.conf /etc/php83/php-fpm.d/www.conf
COPY config/php/php.ini /etc/php83/conf.d/00-custom.ini
COPY config/php/opcache.ini /etc/php83/conf.d/opcache.ini

# create necessary runtime directories and set initial ownership
RUN mkdir -p /run /var/log /.composer && \
    chown -R nobody:nobody /run /var/log /.composer && \
    rm -rf /var/cache/apk/*

# builder stage
FROM base AS builder

LABEL Description="Builder stage for Mediawiki 1.43.1"

# install build dependencies
RUN apk add --no-cache \
  composer \
  diffutils \
  git \
  lua5.1-dev \
  php83-dev \
  build-base

# install wikidiff2
RUN apk add --no-cache --virtual .build-deps-wikidiff2 \
        build-base \
        git \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/php/wikidiff2 \
    && cd wikidiff2 \
    && phpize \
    && ./configure --prefix=/usr --with-php-config=php-config83 \
    && make \
    && make install \
    && cd .. \
    && rm -rf wikidiff2 \
    && apk del .build-deps-wikidiff2

# Ensure the target directory is writable by nobody before switching user
RUN chown -R nobody:nobody /var/www/html

USER nobody

# download and extract MediaWiki
RUN curl -fSL "https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_VERSION}.tar.gz" -o mediawiki.tar.gz && \
  tar -x --strip-components=1 -f mediawiki.tar.gz && \
  # clean downloaded/extracted files
  rm -rf \
    mediawiki.tar.gz \
    UPGRADE SECURITY RELEASE-NOTES-* README.md INSTALL HISTORY FAQ CREDITS COPYING CODE_OF_CONDUCT.md

# install composer dependencies
COPY composer.json /var/www/html/composer.local.json
RUN /usr/bin/php83 /usr/bin/composer.phar config --no-plugins allow-plugins.composer/installers true && \
    /usr/bin/php83 /usr/bin/composer.phar install --no-dev \
        --ignore-platform-reqs \
        --no-ansi \
        --no-interaction \
        --no-scripts && \
    /usr/bin/php83 /usr/bin/composer.phar update --no-dev \
        --no-ansi \
        --no-interaction \
        --no-scripts && \
    # clean up composer cache
    rm -rf /.composer/cache/*

# fix folder names
RUN cd /var/www/html/extensions \
    && mv Vipsscaler VipsScaler \
    && mv Wikiseo WikiSEO \
    && mv Webauthn WebAuthn \
    && mv Oauth OAuth \
    && mv Cirrussearch CirrusSearch \
    && mv Variableslua VariablesLua \
    && mv Templatesandbox TemplateSandbox \
    && mv Simplemathjax SimpleMathJax \
    && mv Randomselection RandomSelection \
    && mv Regexfunctions RegexFunctions \
    && mv MwDiscord Discord \
    && mv Importarticles ImportArticles \
    && mv Labeledsectiontransclusion LabeledSectionTransclusion \
    && mv Msupload MsUpload \
    && mv Checkuser CheckUser \
    && mv Deletepagesforgood DeletePagesForGood \
    && mv Darkmode DarkMode \
    && mv Cldr cldr \
    && mv Shortdescription ShortDescription

FROM base

LABEL Description="Lightweight Mediawiki 1.43.1 container with PHP-FPM 8.3 (Alpine 3.21.3) - Multi-stage build"

WORKDIR /var/www/html

COPY --from=builder /var/www/html /var/www/html
COPY --from=builder /usr/lib/php83/modules/wikidiff2.so /usr/lib/php83/modules/wikidiff2.so


USER nobody
RUN echo 'extension = luasandbox.so' >> /etc/php83/conf.d/luasandbox.ini
RUN echo 'extension = wikidiff2.so' >> /etc/php83/conf.d/wikidiff2.ini

EXPOSE 9000

CMD ["php-fpm83", "-F"]