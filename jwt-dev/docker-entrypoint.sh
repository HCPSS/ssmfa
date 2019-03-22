#!/usr/bin/env bash

# create cert dir
mkdir /sso/cert 2>/dev/null

# create jwt dir
mkdir -p /sso/jwt/www 2>/dev/null

#generate keys
openssl req -newkey rsa:2048 -new -x509 -days 1024 -nodes -out /sso/jwt/jwt.pub -keyout /sso/jwt/jwt.key -config /openssl.cnf

# make sure www-data can read
chmod +r /sso/jwt/jwt.key

# publish the public jwt key
ln -s /sso/jwt/jwt.pub /sso/jwt/www/jwt.pub

# generate config
/generate-config.sh

# start apache
service apache2 start

# start cron for logrotate
nohup cron -f &>/dev/null &

# sleep
tail -f /var/log/saml/simplesamlphp.log
