#!/bin/bash
echo 'Installing docker...'
sudo apt install docker docker.io -y
echo 'Adding user to docker group...'
sudo usermod -aG docker $USER
echo 'Setting up portainer...'
docker pull portainer/portainer-ce:latest
docker volume create portainer_data
docker run -d \
  --name portainer \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  --restart always \
  portainer/portainer-ce:latest
echo 'Done!'
