group "default" {
  targets = ["local"]
}
group "local" {
  targets = ["_local"]
}
group "runtime" {
    targets = ["builds-sshd-amd64"]
}
variable "DOCKER_TAG" {
  default = "latest"
}
variable "DOCKER_REGISTRY" {
  default = "local"
}
variable "DOCKER_REPOSITORY" {
  default = "network"
}
variable "DOCKER_IMAGE_NAME" {
  default = "sshd"
}

target "_common" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64"]
  networks = ["host"]
  buildkit = true
}

target "_local" {
  inherits = ["_common"]
  target = "runtime"
  tags = [
    "local/${DOCKER_REPOSITORY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}",
  ]
  output = [
    "type=docker,name=local/${DOCKER_REPOSITORY}/${DOCKER_IMAGE_NAME}:${DOCKER_TAG}"
  ]
}

target "builds" {
  pull = true
  progress = ["plain", "tty"]
  tags = [
    "${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${i.img}:${DOCKER_TAG}",
  ]
  matrix = {
    i = [
      {
        tgt = "runtime",
        img = "runtime",
      }
    ],
    p = [
      {
        platform = "linux/amd64",
        suffix = "amd64",
      },
      {
        platform = "linux/arm64",
        suffix = "arm64",
      },
    ],
  }
  target = "${i.tgt}"
  name   = "builds-${i.img}-${p.suffix}"
  output = [
    "type=image,name=${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${i.img}:${DOCKER_TAG},push=true",
  ]
  cache-to = [
    "type=registry,ref=${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${i.img}:buildcache,mode=max",
  ]
  cache-from = [
    "type=registry,ref=${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${i.img}:buildcache",
    "type=registry,ref=${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/${i.img}:${DOCKER_TAG}"
  ]
  attest = [
    "type=provenance,mode=max",
    "type=sbom",
  ]
  buildkit = true
  context = "."
  dockerfile = "Dockerfile"
  networks = ["host"]
  platforms = [p.platform]
}
