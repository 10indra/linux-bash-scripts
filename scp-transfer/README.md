# EC2-to-EC2 SCP Transfer Using Dedicated Service Account

## Overview

This project provides a production-oriented approach for performing manual SCP file transfers between Amazon EC2 instances running Red Hat Enterprise Linux (RHEL).

The solution uses:

* Dedicated service account (`svc-transfer`)
* SSH public key authentication (ED25519)
* Password-locked account
* Non-sudo user
* Dedicated transfer directory
* Custom SSH port support
* SELinux-compatible configuration

The design allows any participating EC2 instance to act as either:

* SCP Source
* SCP Target

without impacting existing administrative users such as `icuser`, `ec2-user`, or other operational accounts.

---

## Architecture

```text
+----------------------+
| EC2-A                |
| svc-transfer         |
+----------+-----------+
           |
           | SCP / SSH
           | Port 22
           |
+----------v-----------+
| EC2-B                |
| svc-transfer         |
+----------------------+
```

Each participating server contains:

```text
/home/svc-transfer/.ssh/
├── id_ed25519_svc-transfer
├── id_ed25519_svc-transfer.pub
├── authorized_keys
└── config
```

The same SSH key pair is distributed to all participating servers to support bidirectional SCP transfers.

---

## Security Design

### Service Account

A dedicated account is used:

```text
svc-transfer
```

The account:

* Has no sudo privileges
* Has a locked password
* Uses SSH key authentication only
* Is dedicated exclusively to server-to-server file transfers

### SSH Authentication

Authentication uses:

```text
ED25519
```

Benefits:

* Modern cryptography
* Strong security
* Faster authentication
* Recommended by OpenSSH

### Password Authentication

Password authentication is intentionally disabled.

The account password is locked using:

```bash
passwd -l svc-transfer
```

### Dedicated Transfer Directory

All file transfers should use:

```text
/data/transfer
```

This prevents unnecessary write access to other system locations.

---

## Repository Contents

```text
.
├── 01_setup_svc_transfer.sh
├── 02_generate_key.sh
├── 03_install_key.sh
└── README.md
```

---

## Script Execution Order

### Step 1

Run on ALL participating EC2 instances.

```bash
sudo bash 01_setup_svc_transfer.sh
```

This script:

* Creates the `svc-transfer` user
* Locks the account password
* Removes sudo privileges if present
* Creates `/data/transfer`
* Creates `.ssh` directory
* Applies ownership and permissions
* Restores SELinux contexts

---

### Step 2

Run on ONE EC2 instance only.

Example:

```text
EC2-A
```

Execute:

```bash
sudo bash 02_generate_key.sh
```

This script:

* Generates ED25519 SSH key pair
* Creates `authorized_keys`
* Applies required permissions
* Restores SELinux contexts

Generated files:

```text
id_ed25519_svc-transfer
id_ed25519_svc-transfer.pub
```

---

### Step 3

Copy generated key files to all participating EC2 instances.

Files to distribute:

```text
id_ed25519_svc-transfer
id_ed25519_svc-transfer.pub
```

Destination:

```text
/home/svc-transfer/.ssh/
```

---

### Step 4

Run on ALL participating EC2 instances.

```bash
sudo bash 03_install_key.sh
```

This script:

* Creates `authorized_keys`
* Fixes ownership
* Fixes permissions
* Restores SELinux contexts

---

## SSH Configuration

Example:

```text
Host ec2-a
    HostName 192.168.50.51
    User svc-transfer
    Port 24574
    IdentityFile ~/.ssh/id_ed25519_svc-transfer

Host ec2-b
    HostName 192.168.50.52
    User svc-transfer
    Port 24574
    IdentityFile ~/.ssh/id_ed25519_svc-transfer
```

Location:

```text
/home/svc-transfer/.ssh/config
```

Permissions:

```bash
chmod 600 ~/.ssh/config
```

---

## Validation

### Verify User

```bash
id svc-transfer
```

### Verify No Sudo Access

```bash
sudo -l -U svc-transfer
```

Expected:

```text
User svc-transfer is not allowed to run sudo
```

### Verify SSH

```bash
sudo su - svc-transfer

ssh ec2-b
```

### Verify SCP

```bash
scp test.txt ec2-b:/data/transfer/
```

### Verify Reverse SCP

```bash
scp ec2-b:/data/transfer/test.txt .
```

---

## Security Group Requirements

Allow inbound traffic on the custom SSH port:

```text
TCP 22
```

Recommended source:

```text
Source Security Group
```

instead of broad CIDR ranges.

---

## SELinux

RHEL environments running SELinux require:

```bash
restorecon -Rv /home/svc-transfer
```

The scripts perform this automatically.

---

## Operational Notes

This solution is intended for:

* Manual administrator-initiated file transfers
* Internal EC2-to-EC2 communication
* Production environments requiring dedicated transfer accounts

This solution is not intended to replace:

* AWS DataSync
* S3-based file exchange
* Enterprise Managed File Transfer (MFT) platforms

---

## Rollback

Remove service account:

```bash
sudo userdel -r svc-transfer
```

Remove transfer directory:

```bash
sudo rm -rf /data/transfer
```

Review SSH configuration before deleting shared key material.
