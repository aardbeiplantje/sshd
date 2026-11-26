# AGENTS.md

## Project Overview
Dockerized SSH daemon for secure ingress with internal port forwarding. Alpine-based, no traditional tests or linting.

## Key Commands
- **Build & deploy:** `bash deploy.sh`
- **Stop:** `docker compose down`
- **Build only:** `docker buildx bake local`

## Deployment Prerequisites
All of these variables are required before deploy:
```bash
export SSHD_INTERNAL_FORWARDING_PORT_01=9998
export SSHD_INTERNAL_FORWARDING_PORT_02=9999
export SSHD_IPV6_SUBNET=2a02:a03f:8789:e700:c::/120
export SSHD_IPV6_GATEWAY=2a02:a03f:8789:e700:c::2:1
export SSHD_IPV6_ADDRESS=2a02:a03f:8789:e700:c::2:2
# Optional overrides:
export SSHD_EXTERNAL_FORWARDING_PORT_01=9998
export SSHD_EXTERNAL_FORWARDING_PORT_02=9999
bash deploy.sh
```

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `WORKSPACE` | no | script directory (`${BASH_SOURCE%/*}`) | Directory containing the project files |
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

## Adding Users
Place key files at `$SSHD_AUTHORIZED_KEYS_DIR` (default `~/.ingress_sshd_keys/`):
```
authorized_keys.ingress-user-alice
authorized_keys.ingress-user-bob
```
Users are dynamically created at container startup from these files, so restart the container after adding one.

Key files must be owned by root with mode `644`, and their directory must be owned by root (`StrictModes` rejects other owners with `bad ownership or modes`). Connecting clients should use `-o IdentitiesOnly=yes` with `-i <key>`, since `MaxAuthTries` is 3 and agent keys offered first can exhaust it (`Too many authentication failures`).

## Architecture Notes
- **Entry point:** `sshd.sh` — creates users from authorized_keys, generates host keys, execs sshd
- **Config:** `sshd_config` — chroot to `/sshd/chroot`, pubkey-only auth, no passwords, no agent forwarding
- **Match block:** `ingress-user-*` gets `AllowTcpForwarding remote` and `GatewayPorts yes`
- **Networks:** `dmz-ipv4` (10.99.1.0/24, NAT) and `dmz-ipv6` (2a02:a03f:8789:e700:c::/120, routed)
- **External SSH port:** 22322
- **Build:** `docker-bake.hcl` — local target builds for `DOCKER_PLATFORM` (default: host native, so arm64 on a Pi 5) and outputs to docker daemon; `builds` target pushes multi-arch images

## Git Workflow
- Do not create a feature branch unless explicitly asked; commit on the current branch.

## Constraints
- No root login, no passwords, no TTY, no agent forwarding
- Memory: 128m, PIDs: 100, nofile: 1024
- Volumes: `ssh-host-keys`, `ssh-known-hosts` (persistent)
- `.cocoindex_code/` is gitignored (CocoIndex indexing data)
