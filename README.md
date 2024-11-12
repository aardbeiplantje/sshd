# build.sh
```
bash build.sh
```

# Setup docker swarm:
```
docker swarm init --default-addr-pool 10.0.0.0/8 --default-addr-pool-mask-length 24 --advertise-addr $IP
```
Add a node, on the manager:
```
docker swarm join-token worker
```
On the node, see https://docs.docker.com/network/overlay/ for ports:
```
firewall-cmd --add-port=2377/tcp
firewall-cmd --add-port=7946/tcp
firewall-cmd --add-port=7946/udp
firewall-cmd --add-port=4789/udp
firewall-cmd --add-rich-rule="rule protocol value=esp accept"
firewall-cmd --runtime-to-permanent
docker swarm join --token $TKN_HERE
```
Add labels:
```
docker node update --label-add sshd=1 $HOSTNAME
```

# deploy

Add network:
```
docker network create --ipv6 --subnet fd53:5729:c558:8d8f::/64 sshdipv6 --attachable=true --scope=swarm
```

Deploy stack:
```
export SSHD_EXTERNAL_INGRESS_PORT=2222
export SSHD_INTERNAL_FORWARDING_PORT_01=9998
export SSHD_INTERNAL_FORWARDING_PORT_02=9999
bash deploy.sh
```
