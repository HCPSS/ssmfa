#!/usr/bin/env bash

# connection and tls stuff
cat << EOF > /usr/local/etc/haproxy/haproxy.cfg
global
  user root
  group root

  # Default SSL material locations
  ca-base /etc/ssl/certs
  crt-base /etc/ssl/private

  # Default ciphers to use on SSL-enabled listening sockets.
  # For more information, see ciphers(1SSL). This list is from:
  #  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
  # An alternative list with additional directives can be obtained from
  #  https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
  ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
  ssl-default-bind-options no-sslv3
  tune.ssl.default-dh-param 2048

defaults
  log  global
  mode  http
  option  httplog
  option  dontlognull
    timeout connect 5000
    timeout client  5000
    timeout server  600000
    timeout tunnel  600000
  errorfile 400 /usr/local/etc/haproxy/errors/400.http
  errorfile 403 /usr/local/etc/haproxy/errors/403.http
  errorfile 408 /usr/local/etc/haproxy/errors/408.http
  errorfile 500 /usr/local/etc/haproxy/errors/500.http
  errorfile 502 /usr/local/etc/haproxy/errors/502.http
  errorfile 503 /usr/local/etc/haproxy/errors/503.http
  errorfile 504 /usr/local/etc/haproxy/errors/504.http

#######################
# frontend and all ACLs
#######################
frontend http-in
  bind *:80
  bind *:443 ssl crt /usr/local/etc/haproxy/haproxy.pem
  maxconn 10000

EOF

# service ACLs
echo "$DEV_SERVICE_ACLS" | sed 's/,/\n/g' | while read line
do
  n=$(($n + 1))
  cat << EOF >> /usr/local/etc/haproxy/haproxy.cfg
  # SERVICE $n
  acl ACL_SERVICE_$n $line

EOF
done

# https redirect
cat << EOF >> /usr/local/etc/haproxy/haproxy.cfg
  #############################
  # redirects and backend links
  #############################

  # redirect to https
  redirect scheme https code 301 if !{ ssl_fc }

EOF

# backends
echo "$DEV_SERVICE_BACKENDS" | sed 's/,/\n/g' | while read line
do
  n=$(($n + 1))
  cat << EOF >> /usr/local/etc/haproxy/haproxy.cfg
  # SERVICE $n
  use_backend SERVICE_$n if ACL_SERVICE_$n

EOF
done

# default backend
cat << EOF >> /usr/local/etc/haproxy/haproxy.cfg
  # default redirect
  default_backend DEFAULT_SERVICE

#######################
# backends
#######################

EOF

# backends
echo "$DEV_SERVICE_BACKENDS" | sed 's/,/\n/g' | while read line
do
  n=$(($n + 1))
  cat << EOF >> /usr/local/etc/haproxy/haproxy.cfg
# SERVICE $n
backend SERVICE_$n
  option forwardfor
  server SERVER_$n $line

EOF
done

# default backend
cat << EOF >> /usr/local/etc/haproxy/haproxy.cfg
# DEFAULT BACKEND $n
backend DEFAULT_SERVICE
  option forwardfor
  server DEFAULT_SERVER $DEV_DEFAULT_BACKEND
EOF
