# Shared Bake defaults. Per-image targets live in images/<name>/docker-bake.hcl
# and inherit from `_common`.
#
# Local:
#   make build
#   make build IMAGE=hello
#
# Overrides:
#   REGISTRY=ghcr.io/example/docker-images TAG=dev make build IMAGE=hello

variable "REGISTRY" {
  default = "ghcr.io/breauxaj/docker-images"
}

variable "TAG" {
  default = "latest"
}

# Local builds load into the Docker engine. CI sets this to type=registry when pushing.
variable "OUTPUT" {
  default = "type=docker"
}

variable "SOURCE" {
  default = "https://github.com/breauxaj/docker-images"
}

# Empty means the current platform. CI sets linux/amd64,linux/arm64 when publishing.
variable "PLATFORMS" {
  default = ""
}

target "_common" {
  output     = [OUTPUT]
  platforms  = PLATFORMS == "" ? [] : split(",", PLATFORMS)
  args = {
    VERSION = TAG
  }
  labels = {
    "org.opencontainers.image.source" = SOURCE
  }
}
