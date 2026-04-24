FROM alpine:3.21

# Pin version for reproducible builds (#8)
RUN apk add --no-cache vsftpd=3.0.5-r2

COPY vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
    && chmod 600 /etc/vsftpd/vsftpd.conf

EXPOSE 21
# Kubernetes friendly range
EXPOSE 32100-32110

ENTRYPOINT ["/entrypoint.sh"]
