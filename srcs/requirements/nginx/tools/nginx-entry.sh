#!/bin/sh
set -e

if [ ! -f /etc/nginx/ssl/cert.pem ]; then
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/key.pem \
        -out    /etc/nginx/ssl/cert.pem \
        -days 365 \
        -subj "/C=FR/L=Paris/O=42/CN=${DOMAIN_NAME}"
fi

exec nginx -g "daemon off;"
