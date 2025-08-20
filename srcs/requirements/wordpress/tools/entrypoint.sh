#!/bin/bash
set -e

WP_PATH="/var/www/wordpress"

log() { echo "[WordPress] $*"; }

# --- 1) Download WordPress core if missing ---
if [ ! -f "$WP_PATH/wp-settings.php" ]; then
  log "Downloading WordPress core..."
  tmpdir="$(mktemp -d)"
  wget -q https://wordpress.org/latest.tar.gz -O "$tmpdir/wp.tar.gz"
  tar -xzf "$tmpdir/wp.tar.gz" -C "$tmpdir"
  rsync -a "$tmpdir/wordpress/" "$WP_PATH/"
  chown -R www-data:www-data "$WP_PATH"
  rm -rf "$tmpdir"
  log "Core files placed in $WP_PATH."
else
  log "Core files already present — skipping download."
fi

# --- 2) Wait for MariaDB to be ready ---
log "Waiting for MariaDB..."
until mysqladmin ping -hmariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
  sleep 2
done
log "MariaDB is up."

# --- 3) Configure wp-config.php if missing ---
if [ ! -f "$WP_PATH/wp-config.php" ]; then
  log "Creating wp-config.php..."
  cp "$WP_PATH/wp-config-sample.php" "$WP_PATH/wp-config.php"
  sed -i "s/database_name_here/${MYSQL_DATABASE}/" "$WP_PATH/wp-config.php"
  sed -i "s/username_here/${MYSQL_USER}/"        "$WP_PATH/wp-config.php"
  sed -i "s/password_here/${MYSQL_PASSWORD}/"    "$WP_PATH/wp-config.php"
  sed -i "s/localhost/mariadb/"                  "$WP_PATH/wp-config.php"
  chown -R www-data:www-data "$WP_PATH"
  log "wp-config.php created."
else
  log "wp-config.php already exists — skipping."
fi

# --- 4) Install WordPress if not installed ---
if ! wp core is-installed --path="$WP_PATH" --allow-root >/dev/null 2>&1; then
  log "Running wp core install..."
  wp core install \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --path="$WP_PATH" \
    --skip-email \
    --allow-root
  log "Core install done."
else
  log "WordPress already installed — skipping install."
fi

# --- 5) Ensure the second user exists (idempotent) ---
if [ -n "${WP_SECOND_USER:-}" ] && [ -n "${WP_SECOND_EMAIL:-}" ] && [ -n "${WP_SECOND_PASSWORD:-}" ]; then
  if ! wp user get "$WP_SECOND_USER" --path="$WP_PATH" --allow-root >/dev/null 2>&1; then
    log "Creating second user: $WP_SECOND_USER"
    wp user create "$WP_SECOND_USER" "$WP_SECOND_EMAIL" \
      --role="${WP_SECOND_ROLE:-author}" \
      --user_pass="$WP_SECOND_PASSWORD" \
      --path="$WP_PATH" \
      --allow-root
  else
    log "Second user already exists — skipping."
  fi
else
  log "Second user vars not set — skipping."
fi

# --- 6) Run PHP-FPM in foreground ---
exec php-fpm7.4 -F

