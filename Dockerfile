FROM alpine:3.21

# Pin version for reproducible builds (#8)
RUN apk add --no-cache vsftpd=3.0.5-r2

COPY fix-ssl-cache.c /tmp/fix-ssl-cache.c
# hadolint ignore=DL3018
RUN apk add --no-cache --virtual .build gcc musl-dev openssl-dev \
    && gcc -shared -fPIC -o /usr/local/lib/fix-ssl-cache.so \
       /tmp/fix-ssl-cache.c -ldl -lssl -lcrypto \
    && apk del .build \
    && rm /tmp/fix-ssl-cache.c

COPY vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
    && chmod 600 /etc/vsftpd/vsftpd.conf

EXPOSE 21
# Kubernetes friendly range
EXPOSE 32100-32110

ENTRYPOINT ["/entrypoint.sh"]
