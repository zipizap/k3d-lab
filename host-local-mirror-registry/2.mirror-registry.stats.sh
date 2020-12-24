#!/usr/bin/env bash
set -x
docker exec -it host-local-mirror-registry find /var/lib/registry/docker/registry/v2/repositories -type d -maxdepth 2
echo "============================================================================================="
docker logs host-local-mirror-registry -f
