SHELL := /bin/bash
.DEFAULT_GOAL := help

IMAGES := $(patsubst images/%/Dockerfile,%,$(wildcard images/*/Dockerfile))
BAKE_FILES := docker-bake.hcl $(wildcard images/*/docker-bake.hcl)
BAKE_FLAGS := $(patsubst %,-f %,$(BAKE_FILES))
BAKE_TARGETS := $(if $(IMAGE),$(IMAGE),$(IMAGES))

REGISTRY ?= ghcr.io/breauxaj/docker-images
TAG ?= latest

.PHONY: help images lint print build new check

help:
	@printf '%s\n' \
		'Targets:' \
		'  make images              List image names' \
		'  make lint [IMAGE=name]   Lint Dockerfiles with Hadolint' \
		'  make print [IMAGE=name]  Print the resolved Bake plan' \
		'  make build [IMAGE=name]  Build image(s) and load into Docker' \
		'  make new NAME=name       Scaffold a new image from templates/image' \
		'' \
		'Variables:' \
		'  IMAGE      Build or lint a single image' \
		'  NAME       Image name for `make new`' \
		'  REGISTRY   Image registry prefix (default: $(REGISTRY))' \
		'  TAG        Image tag (default: $(TAG))'

images:
	@printf '%s\n' $(IMAGES)

lint:
	@command -v hadolint >/dev/null 2>&1 || { echo 'hadolint is required: https://github.com/hadolint/hadolint'; exit 1; }
	@set -euo pipefail; \
	if [ -n "$(IMAGE)" ]; then \
		hadolint --config .hadolint.yaml "images/$(IMAGE)/Dockerfile"; \
	else \
		for image in $(IMAGES); do hadolint --config .hadolint.yaml "images/$$image/Dockerfile"; done; \
	fi

print:
	docker buildx bake $(BAKE_FLAGS) --print $(BAKE_TARGETS)

build:
	REGISTRY=$(REGISTRY) TAG=$(TAG) docker buildx bake --load --provenance=false $(BAKE_FLAGS) $(BAKE_TARGETS)

new:
	@test -n "$(NAME)" || { echo 'NAME is required, e.g. make new NAME=my-tool'; exit 1; }
	./scripts/new-image.sh "$(NAME)"

check: print
	@echo 'Bake definition is valid.'
