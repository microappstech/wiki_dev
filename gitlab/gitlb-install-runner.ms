# GitLab Runner Installation and Configuration (Docker)

This guide explains how to install and configure a GitLab Runner for a self-hosted GitLab instance.

---

# Architecture

```
Developer
    │
    │ git push
    ▼
+------------------------+
| GitLab Server          |
| https://git.mouddakir.dev
+------------------------+
           │
           │ Sends CI/CD jobs
           ▼
+------------------------+
| GitLab Runner          |
| Docker Executor        |
+------------------------+
           │
           ├── dotnet restore
           ├── dotnet build
           ├── dotnet test
           ├── docker build
           └── docker push / deploy
```

---

# Prerequisites

- Docker installed
- Self-hosted GitLab running
- A Project/Group/Instance Runner authentication token

---

# 1. Create the Runner configuration directory

```bash
sudo mkdir -p /srv/gitlab-runner/config
```

---

# 2. Download and start the Runner

```bash
docker run -d \
  --name gitlab-runner \
  --restart always \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest
```

---

# 3. Verify the Runner container

```bash
docker ps
```

Expected:

```
CONTAINER ID   IMAGE                        NAMES
xxxxxxxxxxxx   gitlab/gitlab-runner:latest  gitlab-runner
```

---

# 4. Create a Runner in GitLab

Open GitLab:

```
Project
    ↓
Settings
    ↓
CI/CD
    ↓
Runners
    ↓
New Project Runner
```

Configure the runner:

- Description: `docker-runner`
- Tags (optional): `docker`, `dotnet`
- Run untagged jobs: **Enabled** (or disable if you plan to use tags)
- Protected: according to your needs

Copy the generated **Runner authentication token** (starts with `glrt-...`).

---

# 5. Register the Runner

```bash
docker exec -it gitlab-runner gitlab-runner register
```

Example:

```
GitLab instance URL:
https://git.mouddakir.dev

Runner authentication token:
glrt-xxxxxxxxxxxxxxxx

Runner name:
docker-runner

Executor:
docker

Default Docker image:
mcr.microsoft.com/dotnet/sdk:10.0
```

---

# 6. Verify the registration

List registered runners:

```bash
docker exec -it gitlab-runner gitlab-runner list
```

Example:

```
Listing configured runners
ConfigFile=/etc/gitlab-runner/config.toml

docker-runner
Executor=docker
Token=xxxxxxxx
URL=https://git.mouddakir.dev
```

---

# 7. Verify from GitLab

Go to:

```
Project
    ↓
Settings
    ↓
CI/CD
    ↓
Runners
```

The runner should show:

```
Status: Online
```

---

# 8. Test the Runner

Create a `.gitlab-ci.yml` file:

```yaml
stages:
  - build

build:
  stage: build
  image: mcr.microsoft.com/dotnet/sdk:10.0

  script:
    - dotnet --info
```

Commit and push:

```bash
git add .
git commit -m "Test GitLab Runner"
git push
```

The pipeline should start automatically.

---

# Useful Commands

## View logs

```bash
docker logs -f gitlab-runner
```

## Restart the Runner

```bash
docker restart gitlab-runner
```

## Stop the Runner

```bash
docker stop gitlab-runner
```

## Start the Runner

```bash
docker start gitlab-runner
```

## Remove the Runner

```bash
docker rm -f gitlab-runner
```

---

# Troubleshooting

### Pipeline is stuck

Cause:

```
This job is stuck because you don't have any active runners.
```

Check:

```bash
docker ps
```

Verify the Runner is registered:

```bash
docker exec -it gitlab-runner gitlab-runner list
```

Check logs:

```bash
docker logs -f gitlab-runner
```

Verify the runner is **Online** in:

```
Project
    ↓
Settings
    ↓
CI/CD
    ↓
Runners
```

If the runner is offline, register it again:

```bash
docker exec -it gitlab-runner gitlab-runner register
```
