# Common Dockerfile Requirements

Applies to every Dockerfile, regardless of language or stage count.

## Syntax and Structure

- Put `# syntax=docker/dockerfile:1` on the first line when using BuildKit features such as heredocs, cache mounts, or `COPY --link`.
- Write instruction names in uppercase (`FROM`, `RUN`, `COPY`) and keep one instruction per line.
- Prefer a single `RUN` per logical unit of work; chain related commands with `&&` so they share one layer.

## Base Images

- You MUST NOT use the `latest` tag or an untagged base image in images that are published or deployed. Pin a specific version tag, e.g. `python:3.13-slim-trixie`.
- Pin by digest (`@sha256:...`) when reproducible builds or supply-chain integrity matter.
- Prefer official images and images maintained by the upstream project.
- Choose the smallest base that meets runtime needs, in this order: `scratch`, distroless, `-slim` / Alpine, full distribution image.
- Alpine uses musl libc. Verify that native modules and prebuilt binaries support musl before switching.
- Rebuild images regularly so base image security fixes reach the final image.

## Build Context

- Add a `.dockerignore` next to the Dockerfile and exclude `.git`, build outputs, local dependencies, secrets, and anything the build does not read.
- Copy only what the build needs. A broad `COPY . .` leaks local files into the image and invalidates the cache on unrelated changes.
- Use `COPY` for local files. Reserve `ADD` for extracting a local tarball; `ADD` also fetches remote URLs without verification, which you SHOULD NOT rely on.

## Instructions

- Set the working directory with `WORKDIR`; do not use `RUN cd ...`.
- Use `ENV` for runtime configuration and `ARG` for build-time values. Neither is a safe place for secrets; see [securing-images.md](securing-images.md).
- Declare `ARG` before `FROM` only when the value is needed in the base image reference; redeclare it inside each stage that uses it, because `ARG` does not carry across stages.
- Quote paths and arguments that may contain spaces or shell metacharacters.
- Keep `EXPOSE` accurate. It documents the port but does not publish it.
- Prefer `COPY --chown=...` over a separate `RUN chown -R ...`, which duplicates file data in another layer.
- Use `COPY --link` where possible; it makes the copy independent of previous layers and improves cache reuse.

## Layer Hygiene

- Remove package manager caches and temporary files in the same `RUN` that created them. Files deleted in a later layer remain in the earlier layer.
- Prefer BuildKit cache mounts over deleting caches; see [optimizing-build-cache.md](optimizing-build-cache.md).

## Validation

- Run `hadolint Dockerfile` when available.
- Run `docker build --check .` to catch deprecated instructions and lint warnings.
- Build the image and smoke-test it with `docker run --rm <image> ...` before considering the work done.
- When publishing for multiple architectures, build with `docker buildx build --platform linux/amd64,linux/arm64`.
