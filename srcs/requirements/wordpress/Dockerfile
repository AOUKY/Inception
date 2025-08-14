# 1. Base image: Debian Bullseye (stable Linux distro)
FROM debian:bullseye

# 2. Set environment variable to suppress interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# 3. Install PHP, extensions, and deps to fetch WP
RUN apt-get update && apt-get install -y \
    php-fpm php-mysql php-cli php-curl php-gd \
    php-mbstring php-xml php-zip wget tar && \
    apt-get clean
    
# 5. The site lives here (mounted as a volume at runtime)
WORKDIR /var/www/wordpress

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# 4. PHP-FPM pool for port 9000
RUN mkdir -p /run/php
COPY conf/wordpress.conf /etc/php/7.4/fpm/pool.d/wordpress.conf
RUN rm /etc/php/7.4/fpm/pool.d/www.conf


# 6. Entrypoint: seed WordPress into the volume if empty, then run PHP-FPM
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

