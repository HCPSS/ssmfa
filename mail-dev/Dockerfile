FROM ubuntu:18.04

LABEL maintainer="Nick Vissari <nvissari@hcpss.org>"

ENV TZ America/New_York

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
      postfix \
      curl \
      php \
      php-curl \
      php-dom \
      dovecot-imapd \
      dumb-init

RUN cat /etc/dovecot/conf.d/10-ssl.conf | sed 's/ssl = yes/ssl = no/' > /tmp/10-ssl.conf && \
    mv /tmp/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf && \
    cat /etc/dovecot/conf.d/10-auth.conf | sed 's/#disable_plaintext_auth = yes/disable_plaintext_auth = no/' > /tmp/10-auth.conf && \
    mv /tmp/10-auth.conf /etc/dovecot/conf.d/10-auth.conf

RUN mkdir /var/www/html/mail && \
    cd /var/www/html/mail && \
    curl -sL https://repository.rainloop.net/installer.php | php

RUN useradd -ms /bin/bash test && \
    echo test:test | chpasswd

COPY ./conf/ /etc/postfix/

COPY ./rainloop /rainloop

COPY docker-entrypoint.sh /

ENTRYPOINT [ "dumb-init", "/docker-entrypoint.sh" ]
