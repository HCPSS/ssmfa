#!/usr/bin/env bash

# root will create key if it doesn't exist
if [ ! -f "/jwt/jwt_sync.key" ]
then
  echo "Generating synchronous key for JWT email links"
  openssl genrsa -out /jwt/jwt_sync.key 2048
  chmod +r /jwt/jwt_sync.key
fi

# wait for jwt_auth.pub
while [ "$(curl -s -k -o /dev/null -w "%{http_code}" $MFA_JWT_AUTH_KEY_URL)" != "200" ]
do
  echo "Waiting for jwt_auth.pub"
  sleep 1
done

# get the public key from the auth server
curl -k -s -o /jwt/jwt_auth.pub $MFA_JWT_AUTH_KEY_URL

# run nodemon as server
su node -c "nodemon server.js"
