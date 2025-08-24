
FROM debian:12


RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y php php-fpm php-mysql php-curl \
    php-gd php-mbstring php-xml php-zip \
    curl mariadb-client && \
    apt-get clean


COPY tools/entrypoint.sh entrypoint.sh


RUN chmod +x entrypoint.sh && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp


WORKDIR /var/www/wordpress


ENTRYPOINT ["/entrypoint.sh"]
