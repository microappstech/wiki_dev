# Podman Cheatsheet — Senior DevOps Summary

Quick facts:
- Rootless by default: runs without a daemon as unprivileged user where possible.
- CLI is Docker-compatible for most commands: `podman` ↔ `docker`.

Common commands:

```
podman pull mcr.microsoft.com/dotnet/aspnet:7.0
podman build -t myapp:latest -f Dockerfile .
podman run --rm -p 8080:80 -v mydata:/app/data myapp:latest
podman ps -a
podman images
podman stop <container>
podman rm <container>
podman rmi <image>
```

Rootless notes:
- Use `podman system migrate` after upgrades when needed.
- Manage user storage via `~/.local/share/containers`.

Podman + systemd (recommended for persistent agents):

```
podman generate systemd --name mycontainer -f > /etc/systemd/system/mycontainer.service
sudo systemctl daemon-reload
sudo systemctl enable --now mycontainer.service
```

CI / .NET specifics:
- Build .NET apps with multi-stage Dockerfile; run `dotnet publish -c Release -o out` in SDK stage, copy to runtime stage.
- Use `podman push` to push to private registries (authenticate via `podman login`).

Debugging tips:
- Inspect container: `podman exec -it <id> /bin/bash` or `sh`.
- Logs: `podman logs <id>`.

Networking:
- Rootless uses slirp4netns; for advanced scenarios use CNI and set up proper policies.

Storage & volumes:
- Use named volumes for persistent state: `podman volume create mydata`.

Best practices:
- Prefer ephemeral containers for CI jobs; use systemd units for long-running services.
- Keep images small; use `mcr.microsoft.com/dotnet/aspnet` for runtime and `mcr.microsoft.com/dotnet/sdk` for builds.
