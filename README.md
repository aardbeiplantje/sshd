# sshd

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `WORKSPACE` | no | script directory | Directory containing the project files |
| `DOCKER_IMAGE` | no | `local/network/sshd:latest` | Docker image to use |
| `SSHD_AUTHORIZED_KEYS_DIR` | no | `~/.ingress_sshd_keys/` | Directory containing authorized_keys files |
| `SSHD_EXTERNAL_INGRESS_PORT` | yes | - | External port for SSH ingress (container port 22) |
| `SSHD_INTERNAL_FORWARDING_PORT_01` | yes | - | Internal port for first forwarding target |
| `SSHD_EXTERNAL_FORWARDING_PORT_01` | no | same as `SSHD_INTERNAL_FORWARDING_PORT_01` | External port mapping for first forwarding target |
| `SSHD_INTERNAL_FORWARDING_PORT_02` | yes | - | Internal port for second forwarding target |
| `SSHD_EXTERNAL_FORWARDING_PORT_02` | no | same as `SSHD_INTERNAL_FORWARDING_PORT_02` | External port mapping for second forwarding target |

## Build

```
bash deploy.sh
```

## Deploy

```
export SSHD_EXTERNAL_INGRESS_PORT=2222
export SSHD_INTERNAL_FORWARDING_PORT_01=9998
export SSHD_INTERNAL_FORWARDING_PORT_02=9999
bash deploy.sh
```

## Stop

```
docker compose down
```

## Add Users

Place authorized keys files at dir $SSHD_AUTH_KEYS_DIR, note that the default
`~/.ingress_sshd_keys/`:

``` authorized_keys.ingress-user-<username> ```

Example:
```
$SSHD_AUTH_KEYS_DIR/authorized_keys.ingress-user-alice
$SSHD_AUTH_KEYS_DIR/authorized_keys.ingress-user-bob
```
