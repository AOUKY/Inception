#!/bin/bash
set -e


mysqld_safe --skip-networking &


sleep 5


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


mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown


exec mysqld_safe

