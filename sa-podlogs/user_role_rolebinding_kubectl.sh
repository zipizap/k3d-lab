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
  rm -fv $USERNAME.{key,csr,crt} || true
  kubectl config use-context k3d-myk3dcluster
}

user_recreate_key_csr_crt_kubeconfigUserAndContext() {
  openssl genrsa -out $USERNAME.key 2048
  #openssl ecparam -name prime256v1 -genkey -noout -out $USERNAME.key
  openssl req -new -key $USERNAME.key -out $USERNAME.csr -subj "/CN=$USERNAME"
  
  # Upload csr via API, with CertificateSigningRequest
  YYYYMMDDhhmmss=$(date +%Y%m%d%H%M%S)
  CSR_NAME=$USERNAME-$YYYYMMDDhhmmss
  CSR_NAME=$USERNAME
  kubectl delete csr $CSR_NAME || true
  cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $CSR_NAME
spec:
  groups:
  - system:authenticated
  request: $(cat $USERNAME.csr | base64 | tr -d "\n")
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
  
  # Approve csr
  kubectl get csr
  kubectl certificate approve $CSR_NAME
  
  # Download user crt, from the csr
  kubectl get csr/$CSR_NAME -o yaml
  kubectl get csr/$CSR_NAME -o=jsonpath='{.status.certificate}' | base64 -d > $USERNAME.crt
  
  #ATP:
  # $USERNAME.key
  # $USERNAME.csr   (not needed anymore)
  # $USERNAME.crt
  
  #kubectl get csr


  # Add/Update $KUBECONFIG file with user, context
  kubectl config delete-context $USERNAME || true
  kubectl config delete-user $USERNAME || true
  kubectl config set-credentials \
    $USERNAME \
    --client-key=$PWD/$USERNAME.key \
    --client-certificate=$PWD/$USERNAME.crt \
    --embed-certs=true
  kubectl config set-context \
    $USERNAME \
    --cluster=k3d-myk3dcluster \
    --user=$USERNAME
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


kubectl_usecontext_of_user() {
  # kubectl directly $USERNAME via context
  kubectl config use-context $USERNAME
  kubectl get pods -A -v=6 2>&1 | grep https://   || true
  kubectl -n sa-podlogs get pods 
  #kubectl get pods -A
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
  name: $USERNAME
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
  name: $USERNAME
  namespace: sa-podlogs
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: $USERNAME
subjects:
- kind: User
  name: $USERNAME
  apiGroup: rbac.authorization.k8s.io
EOF
  kubectl -n sa-podlogs get sa,secret,role,rolebindings
}

kubectl_as_user() {
# kubectl --as $USERNAME ... : impersonate (switch to) user authz 
kubectl config use-context k3d-myk3dcluster
#kubectl --as $USERNAME -n sa-podlogs get pods
#kubectl --as $USERNAME -n sa-podlogs logs nginxdeploy-cb686cd9c-twpkx
kubectl --as $USERNAME \
  -n sa-podlogs \
  logs --selector=app=nginxdeploy --timestamps --prefix
}

main() {
  # NOTE: all kubectl commands should be run with cluster-admin privileges
  # gen user priv-key + csr
  USERNAME=myuser

  # initial_cleanup
  # user_recreate_key_csr_crt_kubeconfigUserAndContext
  # cr_deployment_nginx
  cr_role_rolebinding
  kubectl_as_user

}
main "$@"
