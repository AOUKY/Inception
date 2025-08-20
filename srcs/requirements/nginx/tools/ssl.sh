#!/bin/sh
set -e

mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/selfsigned.key \
  -out /etc/nginx/ssl/selfsigned.crt \
  -subj "/C=MA/ST=Chamal/L=Martil/O=42/OU=Inception/CN=${DOMAIN_NAME}"
