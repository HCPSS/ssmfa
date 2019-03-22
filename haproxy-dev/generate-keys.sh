#!/usr/bin/env bash

# create CA
openssl genrsa -out /tmp/rootCA.key 2048

cat << EOF > /tmp/openssl.cnf
[ req ]
default_bits        = 2048
prompt              = no
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256

[ req_distinguished_name ]
C=US
ST=Maryland
L=Ellicott City
O=Dev
OU=IT
CN=ca
EOF

openssl req -x509 -new -nodes -key /tmp/rootCA.key -days 1024 -out /tmp/rootCA.pem -config <( cat /tmp/openssl.cnf )

# write openssl.cnf file
cat << EOF > /tmp/openssl.cnf
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = $DEV_COMMON_NAME

[ $DEV_COMMON_NAME ]
C=US
ST=Maryland
L=Ellicott City
O=Dev
OU=IT
CN=$DEV_COMMON_NAME
EOF

if [ ! -z "$DEV_ALT_NAMES" ]
then
  cat /tmp/openssl.cnf | sed 's/distinguished_name/req_extensions = req_ext\ndistinguished_name/' > /tmp/openssl.cnf.tmp
  mv /tmp/openssl.cnf.tmp /tmp/openssl.cnf
  echo '
[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]' >> /tmp/openssl.cnf

  IPCOUNT=1
  DNSCOUNT=1
  for entry in $(echo $DEV_ALT_NAMES | sed 's/,/ /g')
  do
    if echo $entry | egrep '^[0-9\.]+$' > /dev/null # just an IP
    then
      echo "IP.$IPCOUNT = $entry" >> /tmp/openssl.cnf
      IPCOUNT=$(($IPCOUNT + 1))
    else
      echo "DNS.$DNSCOUNT = $entry" >> /tmp/openssl.cnf
      DNSCOUNT=$(($DNSCOUNT + 1))
    fi
  done
fi

# creat client key and request
openssl req -new -sha256 -nodes -out /tmp/haproxy.csr -newkey rsa:2048 -keyout /tmp/haproxy.key -config <( cat /tmp/openssl.cnf )

# generate signed cert from generated CA
openssl x509 -req -in /tmp/haproxy.csr -CA /tmp/rootCA.pem -CAkey /tmp/rootCA.key -CAcreateserial -out /tmp/haproxy.crt -days 1023 -sha256 -extensions req_ext -extfile /tmp/openssl.cnf

# combine for haproxy config
cat /tmp/haproxy.crt /tmp/haproxy.key > /usr/local/etc/haproxy/haproxy.pem
chmod 600 /usr/local/etc/haproxy/haproxy.pem
