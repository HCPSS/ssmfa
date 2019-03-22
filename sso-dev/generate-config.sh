#!/usr/bin/env bash

SAFE_MFA_BASE_URL=$(echo $MFA_BASE_URL | sed 's/\//\\\//g')

cat /config.php | \
  sed "s/SAFE_MFA_BASE_URL/$SAFE_MFA_BASE_URL/g" | \
  sed "s/'https:\/\/example.com',/'https:\/\/example.com',\n        'baseURL' => '$SAFE_MFA_BASE_URL',/" > /sso/config/config.php

cat /authsources.php | \
  sed "s/ldap.example.org/$MFA_LDAP_HOST/" | \
  sed "s/BASE/$MFA_LDAP_SEARCHBASES/" | \
  sed "s/search_username/$MFA_LDAP_USERNAME/" | \
  sed "s/search_password/$MFA_LDAP_PASSWORD/" | \
  sed "s/389,/$MFA_LDAP_PORT,/" > /sso/config/authsources.php

cp /saml20-idp-hosted.php /sso/metadata/

cat /saml20-sp-remote.php | \
  sed "s/SAFE_MFA_BASE_URL/$SAFE_MFA_BASE_URL/g" > /sso/metadata/saml20-sp-remote.php
