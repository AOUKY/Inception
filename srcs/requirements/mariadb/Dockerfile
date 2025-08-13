
FROM debian:bullseye

# Prevent interaction prompts (like timezone, password)
ENV DEBIAN_FRONTEND=noninteractive

# Install MariaDB
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean 

# Copy the entrypoint script 
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

# Run the entrypoint script as container's main process
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

