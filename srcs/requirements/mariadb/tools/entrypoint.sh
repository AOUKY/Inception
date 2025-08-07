#!/bin/bash
set -e

# Start MariaDB service (required to use mysql CLI)
service mysql start

# Create database and user if they don’t exist (using env vars)
# This part will be explained and added soon

# Keep the container running with the DB
exec mysqld_safe
