#!/usr/bin/env bash
# Paulo Aleixo Campos
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__dbg_on_off=on  # on off
function shw_info { echo -e '\033[1;34m'"$1"'\033[0m'; }
function error { echo "ERROR in ${1}"; exit 99; }
trap 'error $LINENO' ERR
function dbg { [[ "$__dbg_on_off" == "on" ]] || return; echo -e '\033[1;34m'"dbg $(date +%Y%m%d%H%M%S) ${BASH_LINENO[0]}\t: $@"'\033[0m';  }
exec > >(tee -i /tmp/$(date +%Y%m%d%H%M%S.%N)__$(basename $0).log ) 2>&1
set -o errexit
  # NOTE: the "trap ... ERR" alreay stops execution at any error, even when above line is commente-out
set -o pipefail
set -o nounset
set -o xtrace
export PS4='\[\e[44m\]\[\e[1;30m\](${BASH_SOURCE}:${LINENO}):${FUNCNAME[0]:+ ${FUNCNAME[0]}():}\[\e[m\]        '

k() {
  kubectl --context $KUBECTL_CONTEXT "${@}" 
}
proxy_raise() {
  k proxy &> "${__dir}/proxy.log" &
  PROXY_PID=$! 
}
proxy_stop() {
  kill $PROXY_PID
}

restApi_via_curl_and_kubectlProxy() {
  local THE_PATH="${1?missing arg}"
  local TMP_ERR=$(mktemp)
  local TMP_OUT=$(mktemp)
  curl -kv http://127.0.0.1:8001"${THE_PATH}" \
    2>$TMP_ERR  \
    | tee /dev/null > $TMP_OUT
          #/dev/tty
  cat $TMP_ERR $TMP_OUT > "${__dir}"/.curl.lastlog.stderrstdout
  rm -f $TMP_ERR $TMP_OUT &>/dev/null || true
  cat "${__dir}"/.curl.lastlog.stderrstdout
}

restApi_via_kubectlRaw() {
  local THE_PATH="${1?missing arg}"
  k get --raw $THE_PATH \
  | jq -C '.'
}

main() {
  KUBECTL_CONTEXT=k3d-myk3dcluster

  cd "${__dir}"

  # # Call the rest-API using "kubectl" as usual
  # k get pods -A

  # # To get examples of rest-api PATHs, run kubectl --v=9 like this:
  # kubectl get pods -A --v=9


  # # Call the rest-API using "kubectl proxy" and then curl http://127.0.0.1:8001
  # proxy_raise
  # restApi_via_curl_and_kubectlProxy /api 
  # #restApi_via_curl_and_kubectlProxy /api/v1/namespaces/sa-podlogs/configmaps?watch=true
  # proxy_stop 


  # Call the rest-API using "kubectl --raw" (without proxy or curl)
  restApi_via_kubectlRaw /api
  restApi_via_kubectlRaw /api/v1/pods?limit=20
  restApi_via_kubectlRaw /api/v1/pods?limit=1
  #restApi_via_kubectlRaw /api/v1/namespaces/sa-podlogs/pods?watch=true

  shw_info "==== Execution complete ===="

}
 main "${@}"
