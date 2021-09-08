#!/usr/bin/env bash
# Paulo Aleixo Campos
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
function shw_info { echo -e '\033[1;34m'"$1"'\033[0m'; }
function error { echo "ERROR in ${1}"; exit 99; }
trap 'error $LINENO' ERR
PS4='████████████████████████${BASH_SOURCE}@${FUNCNAME[0]:-}[${LINENO}]>  '
set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace


K3D_DOCKER_NET=k3d-$(k3d cluster list -o json | jq -r '.[0].name')
  # k3d-myk3dcluster
GOGS_IP_InsideK3DockerNet=$(docker network inspect k3d-myk3dcluster | jq -r '.[0].Containers[] | select(.Name=="gogs") | .IPv4Address' | cut -d'/' -f1 )
  # 172.26.0.5

cat <<EOT

GOGS_IP_InsideK3DockerNet=$GOGS_IP_InsideK3DockerNet

From host, better connect via host-ip:
   http://172.17.0.1:10880
   git clone ssh://git@172.17.0.1:10022/username/myrepo.git

From inside k3d, connect via direct-docker-container-ip  (container ip/ports, not host ip/ports):
   http://${GOGS_IP_InsideK3DockerNet}:3000
   git clone ssh://git@${GOGS_IP_InsideK3DockerNet}/username/myrepo.git

EOT
