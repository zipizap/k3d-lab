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

main() {
  cd "${__dir}"/git-repos
  mkdir -p fleet-infra
  if [[ ! -d fleet-infra ]]
  then 
    GIT_SSH_COMMAND="ssh -F $PWD/user1.ssh.config/config" git clone ssh://git@172.26.0.5/user1/fleet-infra.git
    cd fleet-infra
    git config core.sshCommand "ssh -F $PWD/../user1.ssh.config/config" || true
    cd ..
  else
    cd fleet-infra
    git pull
    cd ..
  fi
  cd "${__dir}"/git-repos
  flux bootstrap git \
    --url=ssh://git@172.26.0.5/user1/fleet-infra.git \
    --branch=master \
    --path=clusters/my-cluster \
    --private-key-file=user1.ssh.config/id_ed25519 --password='' 

  flux reconcile source git flux-system

  flux check
  shw_info ">> Completed successfully"
}
main "${@}"
