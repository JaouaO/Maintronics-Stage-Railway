#!/usr/bin/env bash
set -euo pipefail
mkdir -p /var/log/nginx /var/cache/nginx
# Génère /nginx.conf à partir du template (le vôtre si présent, sinon celui par défaut)
node /assets/scripts/prestart.mjs /assets/nginx.template.conf /nginx.conf
php-fpm -y /assets/php-fpm.conf &
nginx -c /nginx.conf
wait -n
