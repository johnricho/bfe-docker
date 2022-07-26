FROM wordpress:6.0.1-php8.0-fpm-alpine

ARG XDEBUG_VERSION="3.0.0beta1"

# update system
RUN set -ex && apk update && apk upgrade --available

# install Xdebug and enable Xdebug
RUN set -ex && mkdir -p /usr/src/php/ext/xdebug \
	&& curl -fsSL https://pecl.php.net/get/xdebug-${XDEBUG_VERSION} | tar xvz -C "/usr/src/php/ext/xdebug" --strip 1 \
	&& docker-php-ext-install xdebug