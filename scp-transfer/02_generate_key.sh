#!/bin/bash
set -e

USER_NAME="svc-transfer"
SSH_DIR="/home/${USER_NAME}/.ssh"

sudo -u ${USER_NAME} ssh-keygen \
-t ed25519 \
-a 100 \
-f ${SSH_DIR}/id_ed25519_svc-transfer \
-N ""

sudo -u ${USER_NAME} cp \
${SSH_DIR}/id_ed25519_svc-transfer.pub \
${SSH_DIR}/authorized_keys

chmod 600 ${SSH_DIR}/id_ed25519_svc-transfer
chmod 600 ${SSH_DIR}/authorized_keys
chmod 644 ${SSH_DIR}/id_ed25519_svc-transfer.pub

restorecon -Rv ${SSH_DIR} || true

echo "Key generated"
