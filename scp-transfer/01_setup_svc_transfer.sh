#!/bin/bash
set -e

USER_NAME="svc-transfer"

if ! id "${USER_NAME}" >/dev/null 2>&1; then
    useradd -m -s /bin/bash ${USER_NAME}
fi

passwd -l ${USER_NAME} || true

if groups ${USER_NAME} | grep -qw wheel; then
    gpasswd -d ${USER_NAME} wheel || true
fi

mkdir -p /data/transfer

chown ${USER_NAME}:${USER_NAME} /data/transfer

chmod 750 /data/transfer

mkdir -p /home/${USER_NAME}/.ssh

chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.ssh

chmod 700 /home/${USER_NAME}/.ssh

restorecon -Rv /home/${USER_NAME} || true

echo "Completed"
