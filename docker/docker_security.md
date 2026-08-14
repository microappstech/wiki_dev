# Docker Security Reference

## Image hygiene
- Use official or trusted base images.
- Pin versions: `ubuntu:22.04`, `node:20-alpine`.
- Scan images: `docker scan <image>`, `trivy image <image>`.
- Rebuild regularly to apply patches.

## Container runtime
- Run non-root user in container.
- Set `readOnly: true` where possible.
- Drop Linux capabilities: `cap_drop: ["ALL"]` and add only required.
- Limit resources: `mem_limit`, `cpus`.
- Use user namespaces if supported.

## Network and secrets
- Use isolated networks for app tiers.
- Avoid exposing management ports publicly.
- Do not embed secrets in image or source repo.
- Use Docker secrets for swarm or environment variables from secure storage.
- Use `--env-file` and volume-mounted config from protected host paths.

## Build and deployment
- Use multi-stage builds to keep images small.
- Keep Dockerfiles simple and layered.
- Regularly prune unused images and containers.
- Enable image signing and scan before deployment.
