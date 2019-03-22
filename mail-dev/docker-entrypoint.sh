#!/usr/bin/env bash

service postfix start

postmap /etc/postfix/virtual

sleep infinity
