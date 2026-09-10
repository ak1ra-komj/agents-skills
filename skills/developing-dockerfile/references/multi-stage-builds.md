# Multi-Stage Builds

Use multiple stages to keep build toolchains, source code, and intermediate files out of the runtime image.

## Structure

```dockerfile
# syntax=docker/dockerfile:1

FROM golang:1.23-bookworm AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/app ./cmd/app

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/app /app
USER nonroot
ENTRYPOINT ["/app"]
```

- Name stages with `AS <name>` and copy only the artifacts you need with `COPY --from=<name>`.
- The runtime stage SHOULD contain no compilers, package managers, or source code.
- Build development or debug variants with `--target <stage>` instead of shipping them by default.
- A common base stage (`FROM base AS build`) avoids repeating setup across stages. Chained stages (`FROM build AS test`) stay available for copying.

## Choosing the Runtime Base

- `scratch` is the smallest option but has no shell, CA certificates, timezone data, or `/etc/passwd`. Use it only for fully static binaries.
- Distroless (`gcr.io/distroless/static-debian12`, `cc-debian12`, `base-debian12`) adds CA certificates, `/etc/passwd`, and a `nonroot` user without a shell or package manager.
- Use `-slim` or Alpine when the application needs a shell, a package manager, or glibc/musl-specific libraries.
- Static Go and Rust binaries SHOULD be built with `CGO_ENABLED=0` (Go) or a static target (Rust) when targeting `scratch`.

## Copying Artifacts

- Copy individual artifacts rather than whole directories; `COPY --from=build /src /src` drags source and caches into the runtime image.
- `COPY --from` supports `--chown` and `--link`. Use `--chown` so files are owned by the runtime user from the start.
- For Python and Node.js builds, install into a virtualenv or a dedicated prefix, then copy that directory into the runtime stage.

## Cross-Platform Builds

Build on the native platform and cross-compile when the language supports it;
this avoids slow emulated builds. `TARGETOS` and `TARGETARCH` are automatic
build arguments, but they MUST be redeclared with `ARG` inside a stage before a
`RUN` can use them.
