#!/bin/sh
i=5000
for ssh_user in /sshd/authorized_keys/authorized_keys.ingress-user-*; do
    ssh_user=${ssh_user##*/}
    ssh_user=${ssh_user#authorized_keys.}
    echo "$ssh_user:x:$i:$i::/var/empty:/sbin/nologin" >> /etc/passwd
    echo "$ssh_user:x:$i:" >> /etc/group
    echo "$ssh_user:x:$i:" >> /etc/shadow
    i=$((i+1))
done
set -euo pipefail
mkdir -p /sshd/host_keys/etc/ssh
ssh-keygen -A -f /sshd/host_keys/ || exit $?
mv /sshd/host_keys/etc/ssh/* /sshd/host_keys/
rmdir /sshd/host_keys/etc/ssh /sshd/host_keys/etc
exec /usr/sbin/sshd -D -f /etc/ssh/sshd_config
