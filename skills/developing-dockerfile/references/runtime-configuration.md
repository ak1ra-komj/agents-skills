# Runtime Configuration

## Entrypoint and Command

- `ENTRYPOINT` defines the executable; `CMD` provides default arguments that users can override.
- Use exec form (`["binary", "arg"]`) so the process receives signals directly:

```dockerfile
ENTRYPOINT ["/app/server"]
CMD ["--config", "/etc/app/config.yaml"]
```

- Shell form (`ENTRYPOINT /app/server`) runs the command under `/bin/sh -c`. Signal forwarding and exit-code propagation then depend on the shell, and the application may not receive signals directly. Use shell form only when shell features are required.
- Set `WORKDIR` before `ENTRYPOINT` when the application resolves relative paths.

## PID 1 and Signals

- An application that spawns child processes or does not reap zombies SHOULD run under an init. Use `docker run --init`, `tini`, or `dumb-init`:

```dockerfile
ENTRYPOINT ["/sbin/tini", "--", "/app/server"]
```

- Set `STOPSIGNAL` when the application expects a signal other than `SIGTERM`; for example, nginx uses `SIGQUIT` for graceful shutdown.

## Environment and Configuration

- Provide environment-independent defaults with `ENV`. Keep environment-specific values out of the image and inject them at runtime.
- Write logs to stdout/stderr so the platform collects them. Do not write logs to files inside the container.
- Run one process per container. Do not start `systemd` or a supervisor to manage multiple services.
- Avoid `VOLUME` in the Dockerfile unless the image genuinely requires it. It creates anonymous volumes and hides changes made to that path in later instructions.

## Health Checks

- Define `HEALTHCHECK` only when the runtime platform does not provide its own probe. Kubernetes ignores Docker `HEALTHCHECK` and uses its own liveness and readiness probes.
- Use a command already present in the image. Adding `curl` solely for the health check bloats the runtime image.

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD ["/app", "healthcheck"]
```

## Labels

- Add OCI image labels so consumers can trace provenance:

```dockerfile
LABEL org.opencontainers.image.title="my-app" \
      org.opencontainers.image.source="https://example.com/my-app" \
      org.opencontainers.image.version="1.2.3" \
      org.opencontainers.image.revision="<git-sha>"
```

- Keep build metadata in labels, not in `ENV`.
