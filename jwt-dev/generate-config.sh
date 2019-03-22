#!/usr/bin/env bash

SAFE_MFA_BASE_URL=$(echo $MFA_BASE_URL | sed 's/\//\\\//g')

# wait for IdP
while [ "$(curl -s -o /dev/null -w "%{http_code}" http://sso)" != "200" ]
do
  echo "Waiting for IdP"
  sleep 1
done

CERT_DATA=$(echo $(curl -s http://sso/saml/module.php/saml/idp/certs.php/idp.crt | grep -v CERTIFICATE | tr -d "\r" ) | sed 's/ //g')
SAFE_CERT_DATA=$(echo $CERT_DATA | sed 's/\//\\\//g' | sed 's/\+/\\\+/g')

cat /config.php | \
  sed "s/SAFE_MFA_BASE_URL/$SAFE_MFA_BASE_URL/g" | \
  sed "s/'https:\/\/example.com',/'https:\/\/example.com',\n        'baseURL' => '$SAFE_MFA_BASE_URL',/" > /sso/config/config.php

cat /authsources.php | \
  sed "s/SAFE_MFA_BASE_URL/$SAFE_MFA_BASE_URL/" > /sso/config/authsources.php

cat /saml20-idp-remote.php | \
  sed "s/CERT_DATA/$SAFE_CERT_DATA/" | \
  sed "s/SAFE_MFA_BASE_URL/$SAFE_MFA_BASE_URL/g" > /sso/metadata/saml20-idp-remote.php

# configure jwt
ln -s /sso/jwt/www /var/www/html/sso-jwt

ln -s /sso/www /var/www/html/sso-jwt/samlsp

cat /index.php | \
  sed "s/SAFE_MFA_BASE_URL/$SAFE_MFA_BASE_URL/g" > /sso/jwt/www/index.php

cat /jwt-config.php | \
  sed "s/SAFE_MFA_BASE_URL/$SAFE_MFA_BASE_URL/g" > /sso/jwt/config.php
