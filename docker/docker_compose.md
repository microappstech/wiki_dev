# Docker Compose Reference

## Install
- Docker Desktop includes Docker Compose v2.
- Verify:
  docker compose version

## File layout
- `version: "3.9"`
- `services:`
- `networks:`
- `volumes:`

## Common service keys
- `image:`
- `build:`
- `ports:`
- `volumes:`
- `environment:`
- `env_file:`
- `depends_on:`
- `command:`
- `restart:`
- `healthcheck:`

## Commands
- Start detached: `docker compose up -d`
- Stop and remove: `docker compose down`
- Rebuild service: `docker compose up -d --build <service>`
- View logs: `docker compose logs -f`
- Execute shell: `docker compose exec <service> sh`
- List services: `docker compose ps`
- Validate file: `docker compose config`
- Pull images: `docker compose pull`
- Scale service: `docker compose up -d --scale <service>=<n>`

## Best practices
- Use named volumes for persistent data.
- Keep `environment:` minimal; use `env_file:` for secrets.
- Define explicit `restart:` policy.
- Avoid `latest` in production images.
- Use `depends_on` only for startup ordering, not readiness.
