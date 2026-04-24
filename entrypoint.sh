#!/bin/sh
set -e

ETC_DATA="/etc-data"
PASSWD_FILE="$ETC_DATA/pureftpd.passwd"
PDB_FILE="$ETC_DATA/pureftpd.pdb"

cmd_init() {
  USERS_CONF="/etc/pure-ftpd/users.conf"
  PASSWORDS_DIR="/etc/pure-ftpd/passwords"

  touch "$PASSWD_FILE"

  if [ -f "$USERS_CONF" ]; then
    while IFS=: read -r username uid; do
      [ -z "$username" ] && continue

      if ! echo "$username" | grep -qE '^[a-z0-9_-]+$'; then
        echo "Skipping invalid username: $username" >&2
        continue
      fi

      if ! echo "$uid" | grep -qE '^[0-9]+$' || [ "$uid" -lt 1000 ]; then
        echo "Skipping unsafe UID $uid for user $username" >&2
        continue
      fi

      if [ -f "$PASSWORDS_DIR/$username" ]; then
        password=$(tr -d '\n' < "$PASSWORDS_DIR/$username")
        printf '%s\n%s\n' "$password" "$password" | \
          pure-pw useradd "$username" \
            -f "$PASSWD_FILE" \
            -u "$uid" \
            -g "$uid" \
            -d "/home/$username"
      fi

      mkdir -p "/home/$username"
      chown "$uid:$uid" "/home/$username"
      chmod "$([ "${WRITE_ENABLE:-YES}" = "NO" ] && echo 555 || echo 755)" "/home/$username"
    done < "$USERS_CONF"
  fi

  pure-pw mkdb "$PDB_FILE" -f "$PASSWD_FILE"

  if [ -f /etc/pure-ftpd/ssl/tls.key ] && [ -f /etc/pure-ftpd/ssl/tls.crt ]; then
    cat /etc/pure-ftpd/ssl/tls.key /etc/pure-ftpd/ssl/tls.crt > "$ETC_DATA/pure-ftpd.pem"
    chmod 600 "$ETC_DATA/pure-ftpd.pem"
  fi
}

cmd_start() {
  set -- \
    -l "puredb:$PDB_FILE" \
    -u 1000 \
    -A \
    -j \
    -p "${PASV_MIN_PORT:-32100}:${PASV_MAX_PORT:-32110}" \
    -c "${MAX_CLIENTS:-10}" \
    -C "${MAX_PER_IP:-3}" \
    -I 300 \
    -T 120 \
    -O "clf:/var/log/pure-ftpd.log"

  [ -n "${PASV_ADDRESS:-}" ] && set -- "$@" -P "${PASV_ADDRESS}"
  [ -f /etc/ssl/private/pure-ftpd.pem ] && set -- "$@" -Y 1

  touch /var/log/pure-ftpd.log
  tail -f /var/log/pure-ftpd.log &
  exec pure-ftpd "$@"
}

case "${1:-}" in
  init)  cmd_init ;;
  start) cmd_start ;;
  "")    cmd_init; cmd_start ;;
  *)     echo "Usage: $0 [init|start]" >&2; exit 1 ;;
esac
