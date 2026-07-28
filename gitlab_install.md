# GitLab CE Docker Deployment

## Prerequisites
- Docker installed and running
- DNS record for `git.mouddakir.dev` pointing to the host

## Host directories
sudo mkdir -p /srv/gitlab/{config,logs,data}

## Docker network
sudo docker network create git-net

## Run GitLab container
sudo docker run -d \
  --name gitlab \
  --restart unless-stopped \
  --hostname git.mouddakir.dev \
  --network git-net \
  -p 8080:80 \
  -p 8443:443 \
  -p 2222:22 \
  -v /srv/gitlab/config:/etc/gitlab \
  -v /srv/gitlab/logs:/var/log/gitlab \
  -v /srv/gitlab/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ce:latest

## Verify initial password
sudo docker exec -it gitlab cat /etc/gitlab/initial_root_password

## Adjust container memory
sudo docker update --memory 2g --memory-swap 3g gitlab

## Reset root password (optional)
sudo docker exec -it gitlab gitlab-rake "gitlab:password:reset[root]"
