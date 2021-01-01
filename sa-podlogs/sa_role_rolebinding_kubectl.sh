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



initial_cleanup() {
  # cleanup
  #rm -fv $USERNAME.{key,csr,crt} || true
  kubectl config use-context k3d-myk3dcluster
}


cr_deployment_nginx() {
  # create pod to check its logs
  #kubectl -n sa-podlogs run nginx --image=nginx || true
  kubectl \
    -n sa-podlogs \
    create deployment nginxdeploy \
    --replicas=2 --image=nginx \
    || true
  kubectl \
    -n sa-podlogs \
    create deployment nginxdeploy2 \
    --replicas=1 --image=nginx \
    || true
}


cr_sa() {
  cat <<EOT | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: sa-podlogs
  name: $SA_NAME
EOT

  # Add/Update $KUBECONFIG file with user, context
  kubectl config delete-context $SA_NAME || true
  kubectl config delete-user $SA_NAME || true

  SvcAccount_NAME=$SA_NAME
  NAMESPACE=sa-podlogs
  SECRET_NAME=$(kubectl -n $NAMESPACE get serviceaccount "${SvcAccount_NAME}" -o=jsonpath='{.secrets[0].name}')
  TOKEN=$(kubectl -n $NAMESPACE get secret $SECRET_NAME -o=jsonpath='{.data.token}' | base64 -d)

  kubectl config set-credentials \
    $SA_NAME \
    --token=$TOKEN
  kubectl config set-context \
    $SA_NAME \
    --cluster=k3d-myk3dcluster \
    --user=$SA_NAME
}



cr_role_rolebinding() {
  # role, rolebinding
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: sa-podlogs
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: sa-podlogs
  name: $SA_NAME
rules:
# minimal pod permitions, to enable pods/log by label
- apiGroups: [""]
  resources: ["pods"]
  #resourceNames: ["my-configmap"]
  verbs: ["list"]
- apiGroups: [""]
  resources: ["pods/log"]
  #resourceNames: ["nginxdeploy2-69db9bf477-2rt7x"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $SA_NAME
  namespace: sa-podlogs
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: $SA_NAME
subjects:
- kind: ServiceAccount
  name: $SA_NAME
  namespace: sa-podlogs    # ?maybe unnecessary?
EOF
  kubectl -n sa-podlogs get sa,secret,role,rolebindings
}

kubectl_with_saToken() {
  # kubectl config use-context k3d-myk3dcluster
  # SA_NAMESPACE=sa-podlogs
  # "${__dir}"/kubectl_with_sa_token.sh $SA_NAME $SA_NAMESPACE \
  #    logs --selector=app=nginxdeploy --timestamps --prefix

  kubectl config use-context $SA_NAME
  #kubectl get pods -A
  kubectl -n sa-podlogs get pods
  kubectl -n sa-podlogs \
    logs --selector=app=nginxdeploy --timestamps --prefix

}

main() {
  # NOTE: all kubectl commands should be run with cluster-admin privileges
  # gen user priv-key + csr
  SA_NAME=mysa

  initial_cleanup
  cr_deployment_nginx
  cr_sa
  cr_role_rolebinding
  kubectl_with_saToken
  
  shw_info "=== execution completed successfully ==="
}
main "$@"
