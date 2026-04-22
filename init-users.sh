#!/bin/sh
set -e

USERS_CONF="/etc/vsftpd/users.conf"
PASSWORDS_DIR="/etc/vsftpd/passwords"
ETC_DATA="/etc-data"

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

    if ! id "$username" >/dev/null 2>&1; then
      adduser -D -H -u "$uid" "$username"
    fi

    if [ -f "$PASSWORDS_DIR/$username" ]; then
      password=$(tr -d '\n' < "$PASSWORDS_DIR/$username")
      echo "$username:$password" | chpasswd
    fi

    mkdir -p "/home/$username/uploads"
    chown root:root "/home/$username"
    chmod 755 "/home/$username"
    chown "$username:$username" "/home/$username/uploads"
    chmod 755 "/home/$username/uploads"
  done < "$USERS_CONF"
fi

# Export updated auth files to the shared volume (Kubernetes init container path)
if [ -d "$ETC_DATA" ]; then
  cp /etc/passwd "$ETC_DATA/passwd"
  cp /etc/shadow "$ETC_DATA/shadow"
  cp /etc/group  "$ETC_DATA/group"
  chmod 644 "$ETC_DATA/passwd"
  chmod 640 "$ETC_DATA/shadow"
  chmod 644 "$ETC_DATA/group"
fi
