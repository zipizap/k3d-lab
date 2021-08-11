cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-reader
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # ClusterRoles are not namespaced
  name: pod-reader
rules:
- apiGroups: [""]
  # at the HTTP level, the name of the resource
  resources: ["pods"]
  #resourceNames: ["my-configmap"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader
  namespace: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: pod-reader
subjects:
- kind: ServiceAccount
  name: pod-reader
  namespace: kubernetes-dashboard
EOF

SvcAccount_NAME="pod-reader"
./2.dashboard.svcAcct_get_token.sh $SvcAccount_NAME
