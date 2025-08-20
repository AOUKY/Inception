FROM alpine:3.18

RUN apk add --no-cache nginx && \
    mkdir -p /usr/share/nginx/html /etc/nginx/certs

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN apk add --no-cache openssl

COPY tools/ssl.sh /tmp/ssl.sh
RUN sh /tmp/ssl.sh && rm /tmp/ssl.sh

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

