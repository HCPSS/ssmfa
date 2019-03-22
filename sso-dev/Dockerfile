FROM ubuntu:18.04

LABEL maintainer="Nick Vissari <nvissari@hcpss.org>"

ENV TZ America/New_York

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
      curl \
      cron \
      dumb-init \
      apache2 \
      libapache2-mod-php \
      php-xml \
      php-ldap \
      php-curl \
      php-memcache \
      php-date \
      php-bcmath \
      php-pear \
      gcc \
      git \
      make \
      autoconf \
      libc-dev \
      pkg-config \
      libmcrypt-dev \
      php7.2-dev \
      php7.2-mbstring \
      tzdata \
      php-zip && \
    pecl install mcrypt-1.0.1 && \
    bash -c "echo extension=/usr/lib/php/20170718/mcrypt.so > /etc/php/7.2/apache2/conf.d/mcrypt.ini" && \
    bash -c "echo extension=/usr/lib/php/20170718/mcrypt.so > /etc/php/7.2/cli/conf.d/mcrypt.ini" && \
    mkdir /var/log/saml && \
    touch /var/log/saml/simplesamlphp.log && \
    chown www-data:www-data /var/log/saml/simplesamlphp.log && \
    echo "<IfModule mpm_prefork_module>" >> /etc/apache2/sites-available/000-default.conf && \
    echo "  StartServers           5" >> /etc/apache2/sites-available/000-default.conf && \
    echo "  MinSpareServers        5" >> /etc/apache2/sites-available/000-default.conf && \
    echo "  MaxSpareServers        10" >> /etc/apache2/sites-available/000-default.conf && \
    echo "  ServerLimit            20000" >> /etc/apache2/sites-available/000-default.conf && \
    echo "  MaxRequestWorkers      20000" >> /etc/apache2/sites-available/000-default.conf && \
    echo "  MaxConnectionsPerChild 0" >> /etc/apache2/sites-available/000-default.conf && \
    echo "</IfModule>" >> /etc/apache2/sites-available/000-default.conf && \
    echo "" >> /etc/apache2/sites-available/000-default.conf && \
    echo "KeepAlive Off" >> /etc/apache2/sites-available/000-default.conf

WORKDIR /sso

RUN git clone -b simplesamlphp-1.17 https://github.com/simplesamlphp/simplesamlphp.git /sso && \
    ln -s /sso/www /var/www/html/saml

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/ && \
    ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

RUN composer install --prefer-source --no-interaction

COPY . /

EXPOSE 80

ENTRYPOINT ["dumb-init", "/docker-entrypoint.sh"]
