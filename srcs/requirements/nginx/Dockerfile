FROM alpine:3.18

RUN apk add --no-cache nginx && \
    mkdir -p /usr/share/nginx/html /etc/nginx/certs

COPY conf/nginx.conf /etc/nginx/nginx.conf


COPY html /usr/share/nginx/html

COPY conf/certs/cert.crt /etc/nginx/certs/cert.crt
COPY conf/certs/cert.key /etc/nginx/certs/cert.key

EXPOSE 443
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

