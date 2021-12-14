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
set -o xtrace

rm -v jane.*  || true
kubectl delete csr jane || true
kubectl config delete-context jane || true
kubectl config delete-user jane || true
kubectl delete clusterrolebinding mygroup_2_cluster-admin || true

openssl genrsa -out jane.key 2048
#openssl req -new -key jane.key -subj "/CN=jane/O=mygroup" -out jane.csr
openssl req -new -key jane.key -subj "/CN=jane" -out jane.csr
cat > jane.csr.yaml <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: jane
spec:
  request: $(cat jane.csr | base64 | tr -d "\n")
  signerName: kubernetes.io/kube-apiserver-client
# expirationSeconds: 86400  # one day
  usages:
  - client auth
EOF
kubectl apply -f jane.csr.yaml
kubectl get csr
kubectl certificate approve jane
kubectl get csr jane -o jsonpath='{.status.certificate}'| base64 -d > jane.crt
#openssl x509 -noout -text -in jane.crt

kubectl config set-credentials jane --client-key=jane.key --client-certificate=jane.crt --embed-certs=true
kubectl config set-context jane --cluster=k3d-myk3dcluster --user=jane
kubectl config get-contexts

#kubectl create clusterrolebinding mygroup_2_cluster-admin --clusterrole=cluster-admin --group=mygroup
kubectl create clusterrolebinding mygroup_2_cluster-admin --clusterrole=cluster-admin --user=jane

kubectl get csr jane -o yaml | grep -A5 groups:
kubectl --context jane get pod -A

shw_info "All completed successfully"
