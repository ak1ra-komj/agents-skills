# Dockerfile Reference Code Blocks

Canonical patterns to compose from when writing a Dockerfile. Include only the blocks the image actually needs, and adapt package names and paths to the project.

## Minimal Single-Stage

```dockerfile
# syntax=docker/dockerfile:1

FROM python:3.13-slim-trixie

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN useradd --system --uid 1001 --create-home app
USER 1001:1001

EXPOSE 8000
ENTRYPOINT ["python", "-m", "app"]
```

## Package Installation

Debian / Ubuntu without cache mounts:

```dockerfile
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*
```

Debian / Ubuntu with BuildKit cache mounts (no cleanup needed):

```dockerfile
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl
```

Alpine:

```dockerfile
RUN apk add --no-cache ca-certificates
```

## Non-Root User

Debian / Ubuntu:

```dockerfile
RUN groupadd --system --gid 1001 app \
    && useradd --system --uid 1001 --gid app --no-create-home --shell /usr/sbin/nologin app
```

Alpine:

```dockerfile
RUN addgroup -S -g 1001 app \
    && adduser -S -u 1001 -G app -H -s /sbin/nologin app
```

Then copy with ownership and switch user:

```dockerfile
COPY --chown=1001:1001 --from=build /out/app /app
USER 1001:1001
```

## Multi-Stage Go (Static, Distroless)

```dockerfile
# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM golang:1.23-trixie AS build
ARG TARGETOS
ARG TARGETARCH
WORKDIR /src
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 \
    go build -trimpath -ldflags="-s -w" -o /out/app ./cmd/app

FROM gcr.io/distroless/static-debian13:nonroot
COPY --from=build /out/app /app
USER nonroot
ENTRYPOINT ["/app"]
```

## Multi-Stage Node.js

```dockerfile
# syntax=docker/dockerfile:1

FROM node:22-trixie-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci
COPY . .
RUN npm run build

FROM node:22-trixie-slim
ENV NODE_ENV=production
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --omit=dev
COPY --from=build /app/dist ./dist
USER node
ENTRYPOINT ["node", "dist/server.js"]
```

## Multi-Stage Python (Virtualenv)

```dockerfile
# syntax=docker/dockerfile:1

FROM python:3.13-slim-trixie AS build
WORKDIR /app
RUN python -m venv /venv
ENV PATH="/venv/bin:${PATH}"
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip pip install -r requirements.txt
COPY . .

FROM python:3.13-slim-trixie
WORKDIR /app
COPY --from=build /venv /venv
COPY --from=build /app /app
ENV PATH="/venv/bin:${PATH}"
USER 1001:1001
ENTRYPOINT ["python", "-m", "app"]
```

## Build Secret

```dockerfile
RUN --mount=type=secret,id=netrc,target=/root/.netrc pip install -r requirements.txt
```

```bash
docker build --secret id=netrc,src="${HOME}/.netrc" .
```

## Heredoc for Multi-Line Scripts

Requires `# syntax=docker/dockerfile:1`:

```dockerfile
RUN <<EOF
set -eux
apt-get update
apt-get install -y --no-install-recommends ca-certificates
rm -rf /var/lib/apt/lists/*
EOF
```

## .dockerignore

```text
.git
.gitignore
.env
*.pem
node_modules
dist
build
Dockerfile*
compose*.yml
README.md
```

## Build, Verify, and Scan

```bash
docker build --check .
docker buildx build --platform linux/amd64,linux/arm64 --sbom=true --provenance=true \
    -t example/app:1.2.3 .
docker run --rm example/app:1.2.3 --version
trivy image example/app:1.2.3
```

## CI Cache Export

```bash
docker buildx build \
    --cache-from type=registry,ref=example/app:buildcache \
    --cache-to type=registry,ref=example/app:buildcache,mode=max \
    -t example/app:1.2.3 .
```
