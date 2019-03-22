#!/usr/bin/env bash

# replace example domain with domain from env
cat /etc/postfix/main.cf | sed "s/example.dev/$MAIL_DOMAIN/g" > /tmp/main.cf
mv /tmp/main.cf /etc/postfix/main.cf
cat /etc/postfix/virtual | sed "s/example.dev/$MAIL_DOMAIN/g" > /tmp/virtual
mv /tmp/virtual /etc/postfix/virtual

service postfix start

postmap /etc/postfix/virtual

service dovecot start

service apache2 start

curl -s -o /dev/null 127.0.0.1/mail/

cat /rainloop/application.ini | sed "s/example.dev/$MAIL_DOMAIN/g" > /var/www/html/mail/data/_data_/_default_/configs/application.ini
cp /rainloop/example.dev.ini "/var/www/html/mail/data/_data_/_default_/domains/$MAIL_DOMAIN.ini"

sleep infinity
