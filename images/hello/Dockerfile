# syntax=docker/dockerfile:1

FROM alpine:3.24

ARG VERSION=dev

LABEL org.opencontainers.image.title="hello" \
      org.opencontainers.image.description="Example image for the docker-images monorepo"

RUN adduser -D -u 1000 app
USER 1000
WORKDIR /home/app

ENV VERSION="${VERSION}"

CMD ["sh", "-c", "echo \"hello from ${VERSION}\""]
