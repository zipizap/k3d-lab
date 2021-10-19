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
#set -o xtrace

NOTICE: this was never tried, its a hopefull idea :)
Dont want to spend much more time in this detail, so if necessary improve and test it

cd "${__dir}"
if [[ -d _var_gogs/ ]]
then
  echo "Manually rename directory _var_gogs/ before attremptinbg to restore"
fi
sudo tar xvf "${1?USAGE: $0 a_backup_file.tgz}"
