#!/bin/bash

envsubst \$NOOSFERO_DOMAIN < /tmp/nginx.template > /tmp/nginx-v2.template
envsubst \$NOOSFERO_PATH < /tmp/nginx-v2.template > /etc/nginx/conf.d/default.conf
exec nginx -g 'daemon off;'
