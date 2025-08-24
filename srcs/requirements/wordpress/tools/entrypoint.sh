#!/bin/bash
set -e


chmod -R 755 /var/www/wordpress
chown -R www-data:www-data /var/www/wordpress


until mysqladmin ping -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
  sleep 1
done


if [ ! -f /var/www/wordpress/wp-config.php ]; then
    
    wp core download --allow-root

    
    wp config create --dbhost=mariadb:3306 \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --allow-root

    
    wp core install --url="$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root

    
    wp user create "$WP_SECOND_USER" "$WP_SECOND_EMAIL" \
        --role="$WP_SECOND_ROLE" \
        --user_pass="$WP_SECOND_PASSWORD" \
        --allow-root
fi


sed -i 's@/run/php/php8.2-fpm.sock@9000@' /etc/php/8.2/fpm/pool.d/www.conf


mkdir -p /run/php


php-fpm8.2 -F
