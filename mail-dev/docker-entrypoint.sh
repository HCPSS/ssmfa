#!/usr/bin/env bash

# replace example domain with domain from env
cat /etc/postfix/main.cf | sed "s/example.dev/$MAIL_DOMAIN/g" > /tmp/main.cf
mv /tmp/main.cf /etc/postfix/main.cf
cat /etc/postfix/virtual | sed "s/example.dev/$MAIL_DOMAIN/g" > /tmp/virtual
mv /tmp/virtual /etc/postfix/virtual

service postfix start

postmap /etc/postfix/virtual

sleep infinity
