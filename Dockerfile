FROM ubuntu:20.04

LABEL maintainer="ZoomoVN <zoomovn@gmail.com>"

RUN DEBIAN_FRONTEND=noninteractive

# Install locales package
RUN apt-get update && apt-get install -y locales

# Generate the en_US.UTF-8 locale
RUN locale-gen en_US.UTF-8

# Set environment variables
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=UTF-8
ENV LANG=en_US.UTF-8

ENV TERM xterm

# Install "software-properties-common" (for the "add-apt-repository")
RUN apt-get update && apt-get install -y \
    software-properties-common

# Add the "PHP 8" ppa
RUN add-apt-repository -y \
    ppa:ondrej/php

# Install PHP-CLI 8, some PHP extentions and some useful Tools with APT
RUN apt-get update && apt-get install -y --force-yes \
        php8.1-cli \
        php8.1-common \
        php8.1-curl \
        php8.1-xml \
        php8.1-mbstring \
        php8.1-mcrypt \
        php8.1-mysql \
        php8.1-pgsql \
        php8.1-sqlite \
        php8.1-sqlite3 \
        php8.1-zip \
        php8.1-memcached \
        php8.1-gd \
        php8.1-fpm \
        php8.1-xdebug \
        php8.1-dev \
        libcurl4-openssl-dev \
        libedit-dev \
        libssl-dev \
        libxml2-dev \
        xz-utils \
        sqlite3 \
        libsqlite3-dev \
        git \
        curl \
        vim \
        nano \
        net-tools \
        pkg-config \
        iputils-ping

# remove load xdebug extension (only load on phpunit command)
RUN sed -i 's/^/;/g' /etc/php/8.1/cli/conf.d/20-xdebug.ini

# Add bin folder of composer to PATH.
RUN echo "export PATH=${PATH}:/var/www/html/vendor/bin:/root/.composer/vendor/bin" >> ~/.bashrc

# Load xdebug Zend extension with phpunit command
RUN echo "alias phpunit='php -dzend_extension=xdebug.so /var/www/laravel/vendor/bin/phpunit'" >> ~/.bashrc

# Install mongodb extension
RUN pecl channel-update pecl.php.net && pecl install mongodb
RUN echo "extension=mongodb.so" >> /etc/php/8.1/cli/php.ini

# Install Nodejs
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g gulp-cli bower eslint babel-eslint eslint-plugin-react yarn

# Install SASS
RUN apt-get update \
    && apt-get install -y --no-install-recommends ruby ruby-dev \
    && gem install sass

# Clean up
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add Composer bin directory to PATH
ENV PATH="/root/.composer/vendor/bin:${PATH}"

# Install PHPMetrics, PHPDepend, PHPMessDetector, PHPCopyPasteDetector
RUN composer global require 'squizlabs/php_codesniffer' \
    'phpmetrics/phpmetrics' \
    'pdepend/pdepend' \
    'phpmd/phpmd' \
    'sebastian/phpcpd'

# Create symlink
RUN ln -s /root/.composer/vendor/bin/phpcs /usr/bin/phpcs \
    && ln -s /root/.composer/vendor/bin/pdepend /usr/bin/pdepend \
    && ln -s /root/.composer/vendor/bin/phpmetrics /usr/bin/phpmetrics \
    && ln -s /root/.composer/vendor/bin/phpmd /usr/bin/phpmd \
    && ln -s /root/.composer/vendor/bin/phpcpd /usr/bin/phpcpd

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /var/www/laravel
