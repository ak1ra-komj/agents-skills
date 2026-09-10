---
name: developing-dockerfile
description: Use when writing, reviewing, or refactoring a Dockerfile or Containerfile.
---

# developing-dockerfile skill

## Rule of Thumb

If the project already has Dockerfiles, follow them in terms of base images, structure, and conventions to maintain consistency. If no relevant examples exist, apply the guidelines in this skill and its reference documents.

## Reference Documents

Load **[references/common.md](references/common.md)** first - it covers baseline requirements that apply to every Dockerfile.

Then load only the documents that match the request:

- **[references/optimizing-build-cache.md](references/optimizing-build-cache.md)** - Load when build performance matters, when layers rebuild unexpectedly, or when ordering dependency installation.
- **[references/multi-stage-builds.md](references/multi-stage-builds.md)** - Load when the build toolchain differs from the runtime environment or when compiling from source.
- **[references/securing-images.md](references/securing-images.md)** - Load when hardening an image, handling build-time secrets, or reducing the attack surface.
- **[references/runtime-configuration.md](references/runtime-configuration.md)** - Load when defining `ENTRYPOINT`, `CMD`, `HEALTHCHECK`, labels, or runtime environment variables.
- **[references/reference-code-blocks.md](references/reference-code-blocks.md)** - Load when composing canonical patterns such as non-root users, package installation, cache mounts, and distroless runtimes.
