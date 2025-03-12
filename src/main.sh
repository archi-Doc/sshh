#!/bin/bash

set -e

# Prepare
SSH_PORT=${SSH_PORT:-2222}
SSH_USER=${SSH_USER:-root}
if [ -z "${SSH_PUBLIC_KEY}" ]; then
    echo "Error: SSH_PUBLIC_KEY is not set." >&2
    exit 1
fi

TARGET_UID=$(id -u)
TARGET_GID=$(id -g)

if [ "${SSH_USER}" == "root" ]; then
  if [ "$TARGET_UID" = "0" ] && [ "$TARGET_GID" = "0" ]; then
    HOME_DIRECTORY="/root"
  else
    echo "Error: Both PID and GID must be 0 when the user name is root." >&2
    exit 1
  fi
else
  HOME_DIRECTORY="/home/$SSH_USER"
fi

#script -q -c "echo 'abcd' | su -"
su root <<RRR
abcd

if [ "${SSH_USER}" != "root" ]; then
  if id "${SSH_USER}" &>/dev/null; then
    useradd -m -s /bin/bash -d "$HOME_DIRECTORY" "$SSH_USER"
    echo "User '${SSH_USER}' already exists. Skipping creation."
  else
    useradd -m -s /bin/bash -d "$HOME_DIRECTORY" "$SSH_USER"&>/dev/null
    echo "User '${SSH_USER}' created successfully."
  fi

  usermod -u "${TARGET_UID}" "${SSH_USER}" >/dev/null 2>&1 || echo "Error changing user ID."
  groupmod -g "${TARGET_GID}" "${SSH_USER}" >/dev/null 2>&1 || echo "Error changing group ID."
fi

# Information
echo "SSH port: ${SSH_PORT}"
echo "SSH user: ${SSH_USER}"
echo "SSH public key: ${SSH_PUBLIC_KEY}"

# SSHd
cat << EOF > /etc/ssh/sshd_config
PasswordAuthentication no
ChallengeResponseAuthentication no
KbdInteractiveAuthentication no
UsePAM Yes
PrintMotd no
EOF
if [ -n "$ALLOW_USERS" ]; then
  echo "AllowUsers $ALLOW_USERS" >> /etc/ssh/sshd_config
fi

# Set host key
if [ -n "${HOST_PRIVATE_KEY}" ]; then
  echo "${HOST_PRIVATE_KEY}" > /etc/ssh/hostkey
  chmod 600 /etc/ssh/hostkey
fi

if [ -n "${HOST_PRIVATE_KEY}" ]; then
  /usr/sbin/sshd -p ${SSH_PORT} -h /etc/ssh/hostkey
else
  echo "/usr/sbin/sshd -p ${SSH_PORT}"
  /usr/sbin/sshd -p ${SSH_PORT}
fi


if [ -n "${RSYNC_CONF}" ]; then
  echo "rsync"
  /usr/bin/rsync --daemon --config /etc/rsync.conf
fi

# MOTD
{
    echo ""
    echo "ssh hub container"
} > /etc/motd

mkdir -p "$HOME_DIRECTORY"
chown -f "$SSH_USER:$SSH_USER" "$HOME_DIRECTORY"

echo "ALL ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/nopasswd_all"
chmod 440 "/etc/sudoers.d/nopasswd_all"
RRR

# Bash profile
#touch "${HOME_DIRECTORY}/.bash_profile"
cat << 'EOF' > "${HOME_DIRECTORY}/.bash_profile"
if [ -n "$SSH_CONNECTION" ]; then
  CLIENT_INFO=$(echo "$SSH_CONNECTION" | awk '{print $1" "$2}')
  echo "  User:    $(whoami) ($(id -u):$(id -g))"
  echo "  Address: ${CLIENT_INFO}"
fi
echo
EOF

# Set SSH key
mkdir -p "${HOME_DIRECTORY}/.ssh"
echo "${SSH_PUBLIC_KEY}" > "${HOME_DIRECTORY}/.ssh/authorized_keys"

set +e

# Startup command
for var in $(compgen -v | grep '^StartupCommand'); do
  echo "Executing $var '${!var}'"
  bash -c "${!var}"
done

# Cron job
CRON_JOB=""
for var in $(compgen -v | grep '^CronJob'); do
  echo "Adding $var '${!var}'"
  CRON_JOB+="${!var}"$'\n'
done

if [ -n "$CRON_JOB" ]; then
  echo "$CRON_JOB" | crontab -u "$SSH_USER" -
  sudo /etc/init.d/cron start
fi

echo
echo "Sleep infinity..."
trap "exit 0" SIGINT SIGTERM
while true
do
  sleep 1
done
# sleep infinity # init: true

