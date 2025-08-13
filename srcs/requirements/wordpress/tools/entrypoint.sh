#!/bin/bash
set -e  # Stop script if any command fails

WP_PATH="/var/www/wordpress"

# 1. Check if WordPress is already installed
if [ ! -f "$WP_PATH/wp-settings.php" ]; then
    echo "[WordPress] Downloading and setting up..."

    # Create a temporary directory to download WordPress
    tmpdir=$(mktemp -d)

    # Download latest WordPress tarball quietly
    wget -q https://wordpress.org/latest.tar.gz -O "$tmpdir/wp.tar.gz"

    # Extract in the temp directory
    tar -xzf "$tmpdir/wp.tar.gz" -C "$tmpdir"

    # Copy to our target directory using rsync (preserves permissions better than cp)
    rsync -a "$tmpdir/wordpress/" "$WP_PATH/"

    # Set ownership so PHP-FPM (www-data) can read/write
    chown -R www-data:www-data "$WP_PATH"

    echo "[WordPress] Installed successfully!"
else
    echo "[WordPress] Already present — skipping download."
fi

# 2. Start PHP-FPM in foreground (so container keeps running)
exec php-fpm7.4 -F
