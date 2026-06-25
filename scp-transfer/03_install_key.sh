#!/bin/bash
set -e

USER_NAME="svc-transfer"
SSH_DIR="/home/${USER_NAME}/.ssh"

cp \
${SSH_DIR}/id_ed25519_svc-transfer.pub \
${SSH_DIR}/authorized_keys

chown -R ${USER_NAME}:${USER_NAME} ${SSH_DIR}

chmod 700 ${SSH_DIR}
chmod 600 ${SSH_DIR}/id_ed25519_svc-transfer
chmod 600 ${SSH_DIR}/authorized_keys
chmod 644 ${SSH_DIR}/id_ed25519_svc-transfer.pub

restorecon -Rv ${SSH_DIR} || true

echo "Key installed"
