# sshd

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
