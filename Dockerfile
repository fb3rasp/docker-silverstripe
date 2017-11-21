FROM php:7.0-apache


ENV DEBIAN_FRONTEND=noninteractive

# Install components
RUN apt-get update -y && \
    apt-get install -y \
		curl \
		git-core \
		libcurl4-openssl-dev \
        libgd-dev \
		libldap2-dev \
		libmcrypt-dev \
		libtidy-dev \
		libxslt-dev \
		zlib1g-dev \
		libicu-dev \
		g++ \
	    --no-install-recommends && \
	curl -sS https://silverstripe.github.io/sspak/install | php -- /usr/local/bin && \
	curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && \
	pecl install xdebug && \
	rm -r /var/lib/apt/lists/*

# Install PHP Extensions
RUN docker-php-ext-configure intl && \
    docker-php-ext-install intl && \
    docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install pdo && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install mcrypt && \
    docker-php-ext-install soap && \
    docker-php-ext-install tidy && \
    docker-php-ext-install xsl && \
    docker-php-ext-install gd  && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap && \
    docker-php-ext-enable xdebug


COPY config/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY config/php/conf.d/timezone.ini /usr/local/etc/php/conf.d/timezone.ini

COPY config/apache/conf-available/fqdn.conf /etc/apache2/conf-available/fqdn.conf
COPY config/apache/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN	a2enmod rewrite expires remoteip cgid && \
	usermod -u 1000 www-data && \
	usermod -G staff www-data

EXPOSE 80

CMD ["apache2-foreground"]