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

"${__dir}/1.show_gogs_ip_inside_k3d_net.sh

cat <<EOT
  GOGs Credentials:

    admin-user:
        user: root 
        pass: root
        root@root.com

    users:
        user: user1 
        pass: user1
        user1@user1.com
EOT
