cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: clusteradmin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: clusteradmin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: clusteradmin-user
  namespace: kubernetes-dashboard
EOF

SvcAccount_NAME="clusteradmin-user"
./2.dashboard.svcAcct_get_token.sh $SvcAccount_NAME
