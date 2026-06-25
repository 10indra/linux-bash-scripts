# SCP Transfer Service Scripts

This directory contains scripts used to create and configure a dedicated Linux service account for secure file transfers between servers.

## Purpose

The `svc-transfer` account is designed for automated file transfers using SSH/SCP without granting interactive administrative privileges.

Key objectives:

* Create a dedicated service account
* Disable password-based login
* Remove administrative (wheel/sudo) access
* Prepare SSH key authentication
* Create a dedicated transfer directory
* Support secure server-to-server file transfers

---

## Scripts

### 01_setup_svc_transfer.sh

Creates and hardens the service account.

#### Actions performed

1. Creates user `svc-transfer` if it does not exist.
2. Locks the local password.
3. Removes membership from the `wheel` group if present.
4. Creates transfer directory:

```text
/data/transfer
```

5. Sets ownership:

```text
svc-transfer:svc-transfer
```

6. Sets permissions:

```text
750
```

7. Creates SSH directory:

```text
/home/svc-transfer/.ssh
```

8. Applies secure permissions.
9. Restores SELinux contexts (if SELinux is enabled).

#### Execute

```bash
sudo bash 01_setup_svc_transfer.sh
```

#### Expected Output

```text
Completed
```

---

### 03_install_key.sh

Installs the SSH public key used for authentication.

#### Purpose

Enables key-based authentication for the `svc-transfer` account.

#### Typical Actions

* Create or update:

```text
/home/svc-transfer/.ssh/authorized_keys
```

* Set correct ownership and permissions.
* Enable passwordless SSH authentication.

#### Execute

```bash
sudo bash 03_install_key.sh
```

---

## Validation

Verify account:

```bash
id svc-transfer
```

Verify password lock:

```bash
passwd -S svc-transfer
```

Expected:

```text
svc-transfer LK
```

Verify SSH directory:

```bash
ls -ld /home/svc-transfer/.ssh
```

Expected permissions:

```text
drwx------
```

Verify transfer directory:

```bash
ls -ld /data/transfer
```

Expected permissions:

```text
drwxr-x---
```

---

## Security Notes

* Password authentication should remain disabled.
* SSH key authentication is recommended.
* Do not add the account to the `wheel` or `sudo` group.
* Restrict access to authorized administrators only.
* Rotate SSH keys periodically according to company security policy.

---

## Tested On

* Red Hat Enterprise Linux (RHEL)
* Rocky Linux
* AlmaLinux
* CentOS
* Amazon Linux 2
* Amazon Linux 2023

---

## Author

Internal Infrastructure / DevOps Operations
