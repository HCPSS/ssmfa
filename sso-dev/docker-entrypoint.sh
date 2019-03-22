#!/usr/bin/env bash

# create cert dir
mkdir /sso/cert 2>/dev/null

#generate keys
openssl req -newkey rsa:3072 -new -x509 -days 1024 -nodes -out /sso/cert/server.crt -keyout /sso/cert/server.pem -config /openssl.cnf

# make sure www-data can read
chmod +r /sso/cert/server.pem

# generate config
/generate-config.sh

# start apache
service apache2 start

# start cron for logrotate
nohup cron -f &>/dev/null &

# enable example auth module
touch /sso/modules/exampleauth/enable

# sleep
tail -f /var/log/saml/simplesamlphp.log
