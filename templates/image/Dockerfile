# syntax=docker/dockerfile:1

FROM alpine:3.22

ARG VERSION=dev

LABEL org.opencontainers.image.title="__IMAGE__" \
      org.opencontainers.image.description="TODO: describe this image"

RUN adduser -D -u 1000 app
USER app
WORKDIR /home/app

ENV VERSION="${VERSION}"

CMD ["sh", "-c", "echo \"__IMAGE__ ${VERSION}\""]
