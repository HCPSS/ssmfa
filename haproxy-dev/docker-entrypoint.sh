#!/usr/bin/env bash

/generate-keys.sh

/generate-haproxy-config.sh

haproxy -f /usr/local/etc/haproxy/haproxy.cfg
