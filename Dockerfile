FROM alpine:3.21

RUN apk add --no-cache pure-ftpd=1.0.52-r0 \
    && mkdir -p /etc/ssl/private

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 21
# Kubernetes friendly range
EXPOSE 32100-32110

ENTRYPOINT ["/entrypoint.sh"]
