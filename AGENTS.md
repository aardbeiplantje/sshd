# AGENTS.md

## Project Overview
Dockerized SSH daemon for secure ingress with internal port forwarding. Alpine-based, no traditional tests or linting.

## Key Commands
- **Build & deploy:** `bash deploy.sh`
- **Stop:** `docker compose down`
- **Build only:** `docker buildx bake local`

## Deployment Prerequisites
Both ports are required before deploy:
```bash
export SSHD_INTERNAL_FORWARDING_PORT_01=9998
export SSHD_INTERNAL_FORWARDING_PORT_02=9999
# Optional overrides:
export SSHD_EXTERNAL_FORWARDING_PORT_01=9998
export SSHD_EXTERNAL_FORWARDING_PORT_02=9999
bash deploy.sh
```

Defaults: `WORKSPACE` (script dir), `DOCKER_IMAGE=local/network/sshd:latest`, `SSHD_AUTHORIZED_KEYS_DIR=~/.ingress_sshd_keys/`

## Adding Users
Place key files at `$SSHD_AUTHORIZED_KEYS_DIR` (default `~/.ingress_sshd_keys/`):
```
authorized_keys.ingress-user-alice
authorized_keys.ingress-user-bob
```
Users are dynamically created at container startup from these files.

## Architecture Notes
- **Entry point:** `sshd.sh` — creates users from authorized_keys, generates host keys, execs sshd
- **Config:** `sshd_config` — chroot to `/sshd/chroot`, pubkey-only auth, no passwords, no agent forwarding
- **Match block:** `ingress-user-*` gets `AllowTcpForwarding remote` and `GatewayPorts yes`
- **Networks:** `dmz-ipv4` (10.99.1.0/24, NAT) and `dmz-ipv6` (2a02:a03f:8789:e700:c::/120, routed)
- **External SSH port:** 22322
- **Build:** `docker-bake.hcl` — local target outputs to docker daemon; `builds` target pushes multi-arch images

## Constraints
- No root login, no passwords, no TTY, no agent forwarding
- Memory: 128m, PIDs: 100, nofile: 1024
- Volumes: `ssh-host-keys`, `ssh-known-hosts` (persistent)
- `.cocoindex_code/` is gitignored (CocoIndex indexing data)
