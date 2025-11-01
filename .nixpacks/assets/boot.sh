#!/usr/bin/env bash
set -e

export APP_ENV=${APP_ENV:-production}
export APP_DEBUG=${APP_DEBUG:-false}
export TZ=${TZ:-Europe/Paris}
export LOG_CHANNEL=stderr
export LOG_STDERR_FORMATTER="Monolog\\Formatter\\LineFormatter"
export NIXPACKS_PHP_ROOT_DIR="/app/public"

if [ -z "$APP_KEY" ]; then
  echo "[boot] ERREUR: APP_KEY manquante. Renseignez-la dans Railway → Variables."
  exit 1
fi

echo "[boot] package:discover"
php artisan package:discover --ansi || true

echo "[boot] cache(s)"
php artisan config:cache --ansi || true
php artisan route:cache  --ansi || true
php artisan view:cache   --ansi || true
php artisan event:cache  --ansi || true

echo "[boot] dossiers & droits"
mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache
chmod -R 775 storage bootstrap/cache || true

echo "[boot] php-fpm & nginx"
php-fpm -y /assets/php-fpm.conf &
node /assets/scripts/prestart.mjs /assets/nginx.template.conf /nginx.conf
nginx -c /nginx.conf
