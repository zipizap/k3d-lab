#!/usr/bin/env bash
# Paulo Aleixo Campos
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__dbg_on_off=on  # on off
function shw_info { echo -e '\033[1;34m'"$1"'\033[0m'; }
function error { echo "ERROR in ${1}"; exit 99; }
trap 'error $LINENO' ERR
function dbg { [[ "$__dbg_on_off" == "on" ]] || return; echo -e '\033[1;34m'"dbg $(date +%Y%m%d%H%M%S) ${BASH_LINENO[0]}\t: $@"'\033[0m';  }
#exec > >(tee -i /tmp/$(date +%Y%m%d%H%M%S.%N)__$(basename $0).log ) 2>&1
set -o errexit
  # NOTE: the "trap ... ERR" alreay stops execution at any error, even when above line is commente-out
set -o pipefail
set -o nounset
set -o xtrace


main() {
  cd "${__dir}"

  CLUSTER_NAME="${1:-myk3dcluster}"
  k3d cluster \
    create $CLUSTER_NAME \
    --agents=2 \
    --wait

  k3d kubeconfig \
    write mycluster \
    --switch-context \
    --output ./kubectl.yaml
  chmod 600 ./kubectl.yaml

  k3d cluster list
  k3d node list
  source  k3d.source
    # ATP: kubectl/helm ready 
  cat <<EOT
  source $PWD/k3.source
  kubectl get all -A
EOT

}
main "${@}"
