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
set -o xtrace


cd "${__dir}"

# Create local directory for volume.
mkdir -p "${PWD}"/_var_gogs || true

# Use `docker run` for the first time.
docker run -d --name=gogs -p 10022:22 -p 10880:3000 -v $PWD/_var_gogs:/data gogs/gogs:latest
# docker stop gogs && docker rm gogs

K3D_DOCKER_NET=k3d-$(k3d cluster list -o json | jq -r '.[0].name')
  # k3d-myk3dcluster
docker network connect $K3D_DOCKER_NET gogs

./1.show_gogs_ip_inside_k3d_net.sh
