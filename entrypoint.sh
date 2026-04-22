#!/bin/sh
set -e

# In standalone Docker, run user setup before starting vsftpd.
# In Kubernetes, an init container runs init-users.sh instead.
/init-users.sh

exec vsftpd /etc/vsftpd/vsftpd.conf
