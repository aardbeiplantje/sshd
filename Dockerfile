FROM alpine AS sshd-runtime
RUN apk add openssh --no-cache
RUN apk update && apk upgrade

VOLUME /sshd/host_keys
VOLUME /sshd/known_hosts
RUN mkdir -p /sshd/known_hosts
RUN mkdir -p /sshd/host_keys
RUN mkdir -p /sshd/authorized_keys
COPY sshd_config /etc/ssh/sshd_config
COPY sshd.sh /
RUN :> /etc/passwd
RUN :> /etc/group
RUN :> /etc/shadow
RUN echo "root:x:0:0:root:/root:/bin/sh" >> /etc/passwd
RUN echo "sshd:x:22:22:sshd:/dev/null:/sbin/nologin" >> /etc/passwd
RUN echo "root:x:0:" >> /etc/group
RUN echo "sshd:x:22:" >> /etc/group
RUN echo "root:*:16384:0:::" >> /etc/shadow
RUN echo "sshd:*:16384:0:::" >> /etc/shadow

ENTRYPOINT ["/sshd.sh"]
