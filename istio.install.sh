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
export PS4='\[\e[44m\]\[\e[1;30m\](${BASH_SOURCE}:${LINENO}):${FUNCNAME[0]:+ ${FUNCNAME[0]}():}\[\e[m\]	'

try_twice() { "${@}" || { echo ">>> RETRYING ${@}"; "${@}"; } }

istioctl_alias() {
  alias istioctl=$PWD/istioctl
    # ATP: istioctl can be used (is in alias)
  ./istioctl version
}

helm_uninstall_traefik() {
  if helm -n kube-system list | grep traefik  &>/dev/null
  then
    # traefik is present, lets uninstall it
    helm -n kube-system uninstall traefik
  fi
}

install_istio() {
  ## https://docs.microsoft.com/en-us/azure/aks/servicemesh-istio-install?pivots=client-operating-system-linux
  ## https://istio.io/latest/docs/setup/getting-started/
  # Download
  export ISTIO_VERSION=1.8.0
  if ! ./istioctl version &>/dev/null
  then 
    rm $PWD/istioctl &>/dev/null || true
    curl -sL "https://github.com/istio/istio/releases/download/$ISTIO_VERSION/istioctl-$ISTIO_VERSION-linux-amd64.tar.gz" | tar xz
  fi
  istioctl_alias
    # ATP: istioctl can be used (is in alias)

  ./istioctl operator init
  kubectl get all -n istio-operator
  kubectl create ns istio-system

  # IstioOperator: https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/#IstioOperatorSpec
  kubectl apply -f ./istio.operator.install.yaml
  kubectl get all -n istio-system
  timeout 60 kubectl logs -n istio-operator -l name=istio-operator -f || true
  kubectl get all -n istio-system

  # istio integrations
  # TODO: cert-manager install and config
  try_twice kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/grafana.yaml
  try_twice kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/jaeger.yaml
  try_twice kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/kiali.yaml
  try_twice kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/prometheus.yaml
  sleep 60
  kubectl -n istio-system get all
    # ATP: istioctl can be used (is in alias) 
}

uninstall_istio() {
  istioctl_alias
    # ATP: istioctl can be used (is in alias)

  kubectl delete istiooperator istio-control-plane -n istio-system
  kubectl get all -n istio-system

  istioctl operator remove 
  kubectl delete ns istio-system
  kubectl delete ns istio-operator
}

main() {
  # Install istio
  #   $0 
  # Uninstall istio
  #   $0 uninstall
  #

  cd "${__dir}"

  if [[ "${1:-}" == "uninstall" ]]; then
    uninstall_istio
    exit $?
  fi

  helm_uninstall_traefik

  install_istio 
    # ATP: istioctl can be used (is in alias) 

  cat <<EOT
k apply -f <(istioctl kube-inject -f manifests/one-files/busybox.deployment.istio.yaml )
k apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/bookinfo/platform/kube/bookinfo.yaml

istioctl dashboard kiali
istioctl dashboard grafana
istioctl dashboard prometheus
istioctl dashboard jaeger

## Great refs
# IstioOperator: https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/#IstioOperatorSpec
#
# 1 nginx-controller + N Ingress + M Services = 1 Gateway + N VirtualService + M Services: https://rinormaloku.com/istio-practice-routing-virtualservices/
#
# Resume gw, virtualservice, destinationRule: https://medium.com/google-cloud/istio-routing-basics-14feab3c040e
#   . ingressgateway  -  Gateway - VirtualService - (DestinationRule: subsets) - Services  -  Deployment    -    Pod
#     lb: external-ip
#                        tcp/80
#                        hosts     hosts
#                                  paths
#                                                    subsets (host:mySvc;version:)                               app: myApp; version: v1/2                                       
#    
#    *virtualservices* glues *gateway* with *services*
#    *destinationrule* defines *subsets* (from pod-label version:) which can be used by virtualServices
#
EOT
  shw_info "== execution complete =="

}
main "${@}"
