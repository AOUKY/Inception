#!/bin/bash
set -e

# Start MariaDB in background for initialization
mysqld_safe --skip-networking &

# Wait for MariaDB to start
sleep 5

# Set root password and create database/user
mysql -uroot <<-EOSQL
    -- Set root password
    SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
    
    -- Create WordPress database
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
    
    -- Create WordPress user
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    
    -- Grant privileges to WordPress user
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    
    -- Apply changes
    FLUSH PRIVILEGES;
EOSQL

# Stop the temporary server
mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Start MariaDB normally (foreground)
exec mysqld_safe

