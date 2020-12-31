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

# Master-nodes number: 1, 2, ...
SERVERS_NUM=1

# Worker-nodes number: 0, 1, 2, ...
AGENTS_NUM=0    
  # 0, 1, 2, ...
  # NOTE: 0 means there will be no workernodes, only master-node. But the master-node will normally execute workloads, so its ok, and 
  #       in fact is the most memory-optimal setup: cluster in only 1 node
  #       In any case (and at any time), a master node can be tainted to dont execute workloads with:
  #         kubectl taint --overwrite node kubemasterX node-role.kubernetes.io/master=true:NoSchedule
  #       And can be untainted to begin executing workloads with:
  #         kubectl taint nodes kubemasterX node-role.kubernetes.io/master-


#K3D_ADDITIONAL_OPTS="${K3D_ADDITIONAL_OPTS:-}"
K3D_ADDITIONAL_OPTS="${K3D_ADDITIONAL_OPTS:-}"


host-local-mirror-registry_setup() {

  # Assure c8r exists running
  "${__dir}"/host-local-mirror-registry/1.mirror-registry.create.sh

  # Assure c8r host-local-mirror-registry is added into k3d network
  if docker ps | grep host-local-mirror-registry &>/dev/null
  then
    local K3D_DOCKER_NET=k3d-$CLUSTER_NAME
    docker network connect $K3D_DOCKER_NET host-local-mirror-registry || true
  fi
}

main() {
  cd "${__dir}"

  CLUSTER_NAME="${1:-myk3dcluster}"
  k3d cluster \
    create $CLUSTER_NAME \
    --servers=$SERVERS_NUM \
    --agents=$AGENTS_NUM \
    --wait \
    --volume "${__dir}"/registries.yaml:/etc/rancher/k3s/registries.yaml \
    ${K3D_ADDITIONAL_OPTS}


  host-local-mirror-registry_setup


  k3d kubeconfig \
    write $CLUSTER_NAME \
    --switch-context \
    --output ./kubeconfig.yaml
  chmod 600 ./kubeconfig.yaml

  k3d cluster list
  k3d node list
  source  k3d.source
    # ATP: kubectl/helm ready 
  echo "== breathing a couple of mins before checking final state ..."
  sleep 60
  kubectl get pod,service -A
  cat <<EOT
  source $PWD/k3.source
  kubectl get all -A
EOT

}
main "${@}"
