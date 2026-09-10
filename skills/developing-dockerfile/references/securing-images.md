# Securing Images

## Run as Non-Root

- Create a dedicated user and switch to it before `ENTRYPOINT`:

```dockerfile
RUN groupadd --system --gid 10001 app \
    && useradd --system --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app
COPY --chown=app:app --from=build /out/app /app
USER 10001:10001
ENTRYPOINT ["/app"]
```

- Use an explicit numeric UID/GID in `USER`; names may not resolve when the image runs in another environment.
- Prefer an existing non-root user from distroless (`nonroot`) or the base image when one is available.
- Copy files with `COPY --chown` so no later `chown` layer is needed.
- The application SHOULD NOT need write access to its own files. Use mounted volumes for writable state.

## Secrets

- You MUST NOT put secrets in `ARG`, `ENV`, `LABEL`, or `COPY`. Build arguments and environment values are visible in image metadata and history, and copied secrets remain in layers even if deleted later.
- Use BuildKit secret mounts for build-time credentials:

```dockerfile
RUN --mount=type=secret,id=netrc,target=/root/.netrc pip install -r requirements.txt
```

```bash
docker build --secret id=netrc,src="${HOME}/.netrc" .
```

- Use `--mount=type=ssh` for private repositories and `docker build --ssh default`.
- Exclude secret files from the build context with `.dockerignore`.

## Supply Chain

- Verify downloaded artifacts with checksums or signatures. Do not pipe remote scripts directly into a shell (`curl ... | sh`).
- Prefer images that publish provenance. BuildKit can attach SBOM and provenance attestations with `--sbom=true --provenance=true`.
- Scan images with `trivy`, `grype`, or `docker scout` as part of CI.
- Keep base images updated and rebuild on base image security releases.

## Attack Surface

- Remove build tools, package managers, and shells from the runtime stage; use multi-stage builds to avoid installing them there in the first place.
- Install only required packages and use `--no-install-recommends` with apt.
- Prefer a minimal base image over removing packages from a full distribution image.
- Run with `--read-only` and `--security-opt no-new-privileges` at runtime when the application supports it.
