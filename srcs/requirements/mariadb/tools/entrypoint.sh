#!/bin/bash
set -e

# Initialize database if empty
if [ -z "$(ls -A /var/lib/mysql)" ]; then
    echo "Initializing MariaDB database..."
    
    # Install system tables
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
    
    # Start temporary server
    mysqld_safe --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    
    # Wait for server
    for i in {1..30}; do
        if echo 'SELECT 1' | mysql -uroot -S /var/run/mysqld/mysqld.sock; then
            break
        fi
        sleep 1
    done

    # Secure installation
    mysql -uroot -S /var/run/mysqld/mysqld.sock <<-EOSQL
        SET @@SESSION.SQL_LOG_BIN=0;
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE USER='';
        DELETE FROM mysql.user WHERE USER='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DROP DATABASE IF EXISTS test;
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    # Shutdown temporary server
    mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

# Start MariaDB normally
exec mysqld_safe