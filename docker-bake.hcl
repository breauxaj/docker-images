# Shared Bake defaults. Per-image targets live in images/<name>/docker-bake.hcl
# and inherit from `_common`.
#
# Do not set `output` or `platforms` here. The docker exporter cannot load a
# manifest list, which is what you get from multi-platform builds or default
# provenance attestations.
#
# Local loads use `make build` (--load, current platform, provenance off).
# CI pushes use bake-action (registry exporter, multi-platform, attestations).

variable "REGISTRY" {
  default = "ghcr.io/breauxaj/docker-images"
}

variable "TAG" {
  default = "latest"
}

variable "SOURCE" {
  default = "https://github.com/breauxaj/docker-images"
}

target "_common" {
  args = {
    VERSION = TAG
  }
  labels = {
    "org.opencontainers.image.source" = SOURCE
  }
}
