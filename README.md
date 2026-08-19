# docker-images

Monorepo for independently versioned Docker images. Each image is a directory
under `images/`, built with [Docker Bake](https://docs.docker.com/build/bake/)
and published to GHCR.

## Layout

```text
images/<name>/          one Docker image
  Dockerfile
  docker-bake.hcl       Bake target named <name>
  README.md
templates/image/        copy-me starter for a new image
docker-bake.hcl         shared Bake defaults
```

Published names look like:

```text
ghcr.io/breauxaj/docker-images/<name>:<tag>
```

## Prerequisites

- Docker with Buildx
- [Hadolint](https://github.com/hadolint/hadolint) for `make lint`

## Common commands

```sh
make images                 # list images
make lint                   # lint every Dockerfile
make build IMAGE=hello      # build one image and load it locally
make build                  # build every image
make new NAME=my-tool       # scaffold images/my-tool from the template
```

Override the registry or tag when you need to:

```sh
make build IMAGE=hello REGISTRY=ghcr.io/breauxaj/docker-images TAG=dev
```

## Add an image

1. Run `make new NAME=my-tool` (or copy `templates/image/`).
2. Edit the Dockerfile and image README.
3. Build with `make build IMAGE=my-tool`.

The Bake target name, directory name, and published image name should all match.

Images can depend on each other with Bake named contexts (`target:other-image`)
when a shared base image in this repo is the right fit.

## CI

GitHub Actions lints Dockerfiles, builds only images that changed, and pushes
multi-platform images (`linux/amd64`, `linux/arm64`) to GHCR on `develop`,
`main`, and version tags (`v*`). Pull requests build for the runner platform
and do not push.

Tags applied on publish:

- `latest` on `develop` and `main`
- `sha-<git-sha>`
- branch name
- semver from `v*` tags
