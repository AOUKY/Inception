
FROM debian:12


ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean 


COPY conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306


ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

