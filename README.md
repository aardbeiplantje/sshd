# sshd

Dockerized SSH daemon for secure ingress with internal port forwarding. Provides SSH access on a configurable external port and forwards connections to one or two internal targets, using authorized keys for authentication.

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `WORKSPACE` | no | script directory | Directory containing the project files |
| `DOCKER_IMAGE` | no | `local/network/sshd:latest` | Docker image to use |
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

## License

This project is unencumbered software released into the public domain. See [LICENSE](LICENSE) for details.
