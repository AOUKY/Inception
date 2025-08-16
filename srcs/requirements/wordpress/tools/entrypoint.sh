#!/bin/bash
set -e

WP_PATH="/var/www/wordpress"

log() { echo "[WordPress] $*"; }

# --- 0) sanity for required env vars (fail fast if missing) ---
: "${MYSQL_DATABASE:?missing}"
: "${MYSQL_USER:?missing}"
: "${MYSQL_PASSWORD:?missing}"
: "${WP_URL:?missing}"
: "${WP_TITLE:?missing}"
: "${WP_ADMIN_USER:?missing}"
: "${WP_ADMIN_PASSWORD:?missing}"
: "${WP_ADMIN_EMAIL:?missing}"

# --- 1) Seed WordPress files into the (persisted) volume if empty ---
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

# --- 2) Wait for MariaDB to be reachable ---
log "Waiting for MariaDB to be ready..."
until mysqladmin ping -hmariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
  sleep 2
done
log "MariaDB is up."

# --- 3) Create wp-config.php if missing, using env values ---
if [ ! -f "$WP_PATH/wp-config.php" ]; then
  log "Creating wp-config.php..."
  cp "$WP_PATH/wp-config-sample.php" "$WP_PATH/wp-config.php"

  # Replace DB settings
  sed -i "s/database_name_here/${MYSQL_DATABASE}/" "$WP_PATH/wp-config.php"
  sed -i "s/username_here/${MYSQL_USER}/"        "$WP_PATH/wp-config.php"
  sed -i "s/password_here/${MYSQL_PASSWORD}/"    "$WP_PATH/wp-config.php"
  sed -i "s/localhost/mariadb/"                  "$WP_PATH/wp-config.php"

  # Insert unique salts (fallback to openssl if curl fails)
  if SALTS="$(curl -fsSL https://api.wordpress.org/secret-key/1.1/salt/)"; then
    awk -v r="$SALTS" '
      BEGIN{printed=0}
      /AUTH_KEY/ && !printed { print r; printed=1; next }
      !/AUTH_KEY|SECURE_AUTH_KEY|LOGGED_IN_KEY|NONCE_KEY|AUTH_SALT|SECURE_AUTH_SALT|LOGGED_IN_SALT|NONCE_SALT/ { print }
    ' "$WP_PATH/wp-config.php" > "$WP_PATH/wp-config.php.tmp"
    mv "$WP_PATH/wp-config.php.tmp" "$WP_PATH/wp-config.php"
  else
    log "Could not fetch salts; generating locally."
    for k in AUTH_KEY SECURE_AUTH_KEY LOGGED_IN_KEY NONCE_KEY AUTH_SALT SECURE_AUTH_SALT LOGGED_IN_SALT NONCE_SALT; do
      rand="$(openssl rand -base64 48 | tr -d '\n')"
      sed -i "0,/put your unique phrase here/s//${rand}/" "$WP_PATH/wp-config.php"
    done
  fi

  chown -R www-data:www-data "$WP_PATH"
  log "wp-config.php created."
else
  log "wp-config.php already exists — leaving it as is."
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

  # --- 5) Ensure second user exists (role from env, default=author) ---
  : "${WP_SECOND_ROLE:=author}"
  if [ -n "${WP_SECOND_USER:-}" ] && [ -n "${WP_SECOND_EMAIL:-}" ] && [ -n "${WP_SECOND_PASSWORD:-}" ]; then
    if ! wp user get "$WP_SECOND_USER" --path="$WP_PATH" --allow-root >/dev/null 2>&1; then
      log "Creating second user: $WP_SECOND_USER ($WP_SECOND_ROLE)"
      wp user create "$WP_SECOND_USER" "$WP_SECOND_EMAIL" \
        --role="$WP_SECOND_ROLE" \
        --user_pass="$WP_SECOND_PASSWORD" \
        --path="$WP_PATH" \
        --allow-root
    else
      log "Second user already exists — skipping."
    fi
  else
    log "Second user env vars not fully set — skipping creation."
  fi
else
  log "WordPress already installed — skipping wp core install."
fi

# --- 6) Run PHP-FPM in foreground (PID 1, no hacky loops) ---
exec php-fpm7.4 -F

