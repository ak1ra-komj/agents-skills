# Optimizing Build Cache

Docker builds each instruction as a layer and reuses a cached layer while its inputs and parent layers are unchanged. Order instructions so expensive, stable work stays cached and only the final steps rerun.

## Instruction Ordering

- Put rarely changing instructions first and frequently changing instructions last.
- Install dependencies before copying application source:
  1. Copy the dependency manifest and lock file.
  2. Install dependencies.
  3. Copy the source.
- Set `ENV` values that change per commit late in the file; every subsequent layer is invalidated when they change.
- Keep `.dockerignore` current. An unrelated file in the context invalidates `COPY . .`.

Node.js example:

```dockerfile
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
```

## Combine Related Commands

- Each `RUN` creates a layer. Combine commands that depend on each other into one `RUN`.
- `apt-get update` and `apt-get install` MUST share one `RUN`. A cached `update` layer with a stale package index makes `install` fail.
- Cleanup MUST happen in the same `RUN` that created the files:

```dockerfile
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*
```

## BuildKit Cache Mounts

Cache mounts persist package manager caches across builds without storing them in the image:

```dockerfile
RUN --mount=type=cache,target=/root/.cache/pip pip install -r requirements.txt
RUN --mount=type=cache,target=/root/.npm npm ci
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends ...
```

- Use `sharing=locked` for package managers that must not run concurrently.
- Cache mounts do not appear in the final image, so they do not inflate its size. When a cache mount is used, the manual cache cleanup in the same `RUN` becomes unnecessary.
- Go builds cache the compiler and module downloads separately:
  `--mount=type=cache,target=/root/.cache/go-build` and `--mount=type=cache,target=/go/pkg/mod`.

## CI Cache Export

For CI, export and import cache with `--cache-to` and `--cache-from`, for example `type=registry` or `type=gha`. Without this, every CI build starts with an empty cache.

## Debugging Cache Behavior

- Inspect layer sizes with `docker history <image>`.
- Build with `docker buildx build --progress=plain` to see which steps rerun.
- If a layer rebuilds unexpectedly, check what changed in the build context, the `ARG` / `ENV` values the layer consumes, and its parent layers.
