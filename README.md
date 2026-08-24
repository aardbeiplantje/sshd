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

Place authorized keys files at `/mnt/ssd/docker-sshd/authorized-keys/`:
```
authorized_keys.ingress-user-<username>
```

Example:
```
/mnt/ssd/docker-sshd/authorized-keys/authorized_keys.ingress-user-alice
/mnt/ssd/docker-sshd/authorized-keys/authorized_keys.ingress-user-bob
```
