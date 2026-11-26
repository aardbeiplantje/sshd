# sshd

Dockerized SSH daemon for secure ingress with internal port forwarding. Provides SSH access on a configurable external port and forwards connections to one or two internal targets, using authorized keys for authentication.

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `WORKSPACE` | no | script directory | Directory containing the project files |
| `DOCKER_IMAGE` | no | `local/network/sshd:latest` | Docker image to use |
| `DOCKER_PLATFORM` | no | host native platform | Platform for the local build, e.g. `linux/arm64` or `linux/amd64` |
| `SSHD_AUTHORIZED_KEYS_DIR` | no | `~/.ingress_sshd_keys/` | Directory containing authorized_keys files |
| `SSHD_INTERNAL_FORWARDING_PORT_01` | yes | - | Internal port for first forwarding target |
| `SSHD_EXTERNAL_FORWARDING_PORT_01` | no | same as `SSHD_INTERNAL_FORWARDING_PORT_01` | External port mapping for first forwarding target |
| `SSHD_INTERNAL_FORWARDING_PORT_02` | yes | - | Internal port for second forwarding target |
| `SSHD_EXTERNAL_FORWARDING_PORT_02` | no | same as `SSHD_INTERNAL_FORWARDING_PORT_02` | External port mapping for second forwarding target |
| `SSHD_IPV6_SUBNET` | yes | - | IPv6 subnet (e.g., `2a02:a03f:8789:e700:c::/120`) |
| `SSHD_IPV6_GATEWAY` | yes | - | IPv6 gateway address (e.g., `2001:db8:c::2:1`) |
| `SSHD_IPV6_ADDRESS` | yes | - | IPv6 address for the container (e.g., `2001:db8:c::2:2`) |

## Build

```
bash deploy.sh
```

The image is built for the host's native platform by default (`linux/arm64` on a Raspberry Pi 5, `linux/amd64` on x86). To build for another platform, set `DOCKER_PLATFORM`, e.g. `DOCKER_PLATFORM=linux/amd64 bash deploy.sh`.

## Raspberry Pi (Raspberry Pi OS) memory limits

Raspberry Pi OS ships with the memory cgroup controller disabled, so Docker cannot enforce `mem_limit`/`memswap_limit` (128m) and prints:

```
Your kernel does not support memory limit capabilities or the cgroup is not mounted. Limitation discarded.
```

The container still runs, but without the memory cap. To enable it:

1. Append `cgroup_enable=memory cgroup_memory=1` to the end of the existing single line in `/boot/firmware/cmdline.txt` (on older releases: `/boot/cmdline.txt`). Keep it on one line, separated by a space, with no new line added.
2. Reboot.
3. Verify with `grep memory /proc/cgroups` (the `enabled` column should be `1`).

## Deploy

```
export SSHD_INTERNAL_FORWARDING_PORT_01=9998
export SSHD_INTERNAL_FORWARDING_PORT_02=9999
export SSHD_IPV6_SUBNET=2a02:a03f:8789:e700:c::/120
export SSHD_IPV6_GATEWAY=2a02:a03f:8789:e700:c::2:1
export SSHD_IPV6_ADDRESS=2a02:a03f:8789:e700:c::2:2
bash deploy.sh
```

## Stop

```
docker compose down
```

## Add Users

Place authorized keys files at dir $SSHD_AUTHORIZED_KEYS_DIR, note that the default
`~/.ingress_sshd_keys/`:

``` authorized_keys.ingress-user-<username> ```

Example:
```
$SSHD_AUTHORIZED_KEYS_DIR/authorized_keys.ingress-user-alice
$SSHD_AUTHORIZED_KEYS_DIR/authorized_keys.ingress-user-bob
```

Users are created when the container starts, so restart the container after adding a new file (`docker compose restart`).

The files must be owned by root and not writable by group or others, or sshd rejects them with `bad ownership or modes`. The directory containing them must also be owned by root. Files owned by your host user (for example uid 1000) will fail even with `644` permissions:

```
sudo chown root:root $SSHD_AUTHORIZED_KEYS_DIR $SSHD_AUTHORIZED_KEYS_DIR/authorized_keys.ingress-user-<username>
sudo chmod 755 $SSHD_AUTHORIZED_KEYS_DIR
sudo chmod 644 $SSHD_AUTHORIZED_KEYS_DIR/authorized_keys.ingress-user-<username>
```

To connect with a specific key, use `-o IdentitiesOnly=yes` so ssh-agent keys are not offered first. The server allows only 3 failed attempts (`MaxAuthTries 3`), so offering several agent keys can cause `Too many authentication failures`:

```
ssh -p 22322 -o IdentitiesOnly=yes -i ~/.ssh/ingress-user-<username> ingress-user-<username>@<host>
```

## License

This project is unencumbered software released into the public domain. See [LICENSE](LICENSE) for details.
