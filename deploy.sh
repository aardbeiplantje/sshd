#!/bin/bash 
export WORKSPACE=${WORKSPACE:-${BASH_SOURCE%/*}}
export APP_NAME=${APP_NAME:-sshd}
export STACK_NAME=${STACK_NAME:-$APP_NAME}
printf -v now "%(%s)T" -1
export CFG_PREFIX=$STACK_NAME-$now
export STACK_CONFIG=${STACK_CONFIG:-$WORKSPACE}
export STACK_CERTS=${STACK_CERTS:-$WORKSPACE}
export REGISTRY_HTTP_SECRET=${REGISTRY_HTTP_SECRET:-$(uuidgen)}
if [ ! -z "$DOCKER_REGISTRY" -a ! -z "$DOCKER_REGISTRY_USER" -a ! -z "$DOCKER_REGISTRY_PASS" ]; then
    export DOCKER_REGISTRY_PASS DOCKER_REGISTRY_USER DOCKER_REGISTRY
    printenv DOCKER_REGISTRY_PASS \
        |docker login -u $DOCKER_REGISTRY_USER $DOCKER_REGISTRY --password-stdin
else
    export DOCKER_REGISTRY=${DOCKER_REGISTRY:-local}
    export DOCKER_REPO=${DOCKER_REPO:-$APP_NAME}
fi
export DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-$APP_NAME}
export DOCKER_REGISTRY
docker stack deploy \
    -c $WORKSPACE/$APP_NAME.yml \
    --with-registry-auth \
    --detach=false \
    $STACK_NAME
