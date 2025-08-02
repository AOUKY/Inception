FROM alpine:3.18

RUN apk add --no-cache nginx && \
    mkdir -p /usr/share/nginx/html

COPY conf/nginx.conf /etc/nginx/nginx.conf


COPY html /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

