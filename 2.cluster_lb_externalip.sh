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
shopt -s inherit_errexit
set -o xtrace


source k3d.source
LB_NAMESPACE=$(kubectl get service -A | grep LoadBalancer | head -1 | awk '{ print $1 }')
LB_SERVICE=$(kubectl get service -A | grep LoadBalancer | head -1 | awk '{ print $2 }')
kubectl -n $LB_NAMESPACE get service/$LB_SERVICE -o jsonpath="{.status.loadBalancer.ingress[*].ip}"
