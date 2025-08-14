
FROM debian:bullseye

# Prevent interaction prompts (like timezone, password)
ENV DEBIAN_FRONTEND=noninteractive

# Install MariaDB
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean 

# Copy the entrypoint script 
COPY conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

# Run the entrypoint script as container's main process
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

