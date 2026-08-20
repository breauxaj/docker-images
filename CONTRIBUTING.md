# Contributing

## Add an image

```sh
make new NAME=my-tool
```

That copies `templates/image/` to `images/my-tool/` and replaces `__IMAGE__`.

Keep these names the same:

- directory: `images/my-tool`
- Bake target in `images/my-tool/docker-bake.hcl`
- published image: `ghcr.io/breauxaj/docker-images/my-tool`

Then:

1. Replace the placeholder Dockerfile and README.
2. Keep the build context small with `.dockerignore`.
3. Run `make lint IMAGE=my-tool` and `make build IMAGE=my-tool`.

## Image conventions

- Prefer a pinned major/minor base tag (`alpine:3.22`, not `alpine:latest`).
- Run as a non-root user when the image does not need root.
- Pass version information with `ARG VERSION` so Bake/CI can inject it.
- Put image-specific Bake options (extra tags, matrices, build args) in the
  image's `docker-bake.hcl`. Shared labels and output defaults stay in the
  root `docker-bake.hcl`.

## CI notes

- Changing an image directory rebuilds that image only.
- Changing shared files (`docker-bake.hcl`, workflows, scripts, Makefile)
  rebuilds every image.
- Dependabot watches GitHub Actions and each image Dockerfile listed in
  `.github/dependabot.yml`. Add a `package-ecosystem: docker` entry when you
  add an image.
