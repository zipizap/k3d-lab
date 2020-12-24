#!/usr/bin/env bash

# This host-local-mirror-registry will act as a proxy for https://registry-1.docker.io
# It works only as an image-caching-proxy, but you cannot "push" images into it (for that, deploy a second registry)
# It will cache images untill they become unused for some time
# Images with tag are always hash-checked against upstream docker-hub, to update if necessary (more details in docker page, project "registry")
#
# Its usefull to cache images for k3d repeated deployments, but its not very usefull for the host-docker daemon which should never use this as its caching-proxy (a container proxying its own daemon... hmm...)
# Also, remember that this is only a caching-proxy, and nobody can "docker push" images into it. Only proxy

docker ps | grep host-local-mirror-registry &>/dev/null && { echo "Docker container host-local-mirror-registry already running - skipping"; exit 0; }

# Assure volume exists
docker volume inspect host-local-mirror-registry &>/dev/null || docker volume create host-local-mirror-registry

# Run c8r
docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name=host-local-mirror-registry \
  -e REGISTRY_PROXY_REMOTEURL="https://registry-1.docker.io" \
  -e REGISTRY_STORAGE_DELETE_ENABLED=true  \
  -v host-local-mirror-registry:/var/lib/registry \
  registry:2




