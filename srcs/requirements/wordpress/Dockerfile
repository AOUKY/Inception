# 1. Base image: Debian Bullseye (stable Linux distro)
FROM debian:bullseye

# 2. Set environment variable to suppress interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# 3. Install PHP, extensions, and deps to fetch WP
RUN apt-get update && apt-get install -y \
    php-fpm php-mysql php-cli php-curl php-gd \
    php-mbstring php-xml php-zip wget tar && \
    apt-get clean

# 4. PHP-FPM pool for port 9000
RUN mkdir -p /run/php
COPY conf/wordpress.conf /etc/php/7.4/fpm/pool.d/wordpress.conf
RUN rm /etc/php/7.4/fpm/pool.d/www.conf

# 5. The site lives here (mounted as a volume at runtime)
WORKDIR /var/www/wordpress

# 6. Entrypoint: seed WordPress into the volume if empty, then run PHP-FPM
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# # 1. Base image: Debian Bullseye (stable Linux distro)
# FROM debian:bullseye

# # 2. Set environment variable to suppress interactive prompts
# ENV DEBIAN_FRONTEND=noninteractive

# # 3. Install PHP, extensions, and dependencies
# RUN apt-get update && apt-get install -y \
#     php-fpm php-mysql php-cli php-curl php-gd \
#     php-mbstring php-xml php-zip wget unzip && \
#     apt-get clean

# # 4. Create custom PHP-FPM configuration
#     # Required directory for PHP-FPM
# RUN mkdir -p /run/php  
# COPY conf/wordpress.conf /etc/php/7.4/fpm/pool.d/wordpress.conf
#     # Remove default config
# RUN rm /etc/php/7.4/fpm/pool.d/www.conf  

# # 5. Download and extract WordPress
# RUN wget https://wordpress.org/latest.zip -O /tmp/wordpress.zip && \
#     unzip /tmp/wordpress.zip -d /var/www/ && \
#     rm /tmp/wordpress.zip

# # 6. Set proper permissions
# RUN chown -R www-data:www-data /var/www/wordpress

# # 7. Set working directory
# WORKDIR /var/www/wordpress

# # 8. Expose port 9000
# EXPOSE 9000

# # 9. Start PHP-FPM in foreground mode
# CMD ["php-fpm7.4", "-F"]