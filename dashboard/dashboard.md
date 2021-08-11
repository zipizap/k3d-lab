# Install

With a running cluster + kubectl configured, run:
```
./1.dashboard_create.sh
```


# Tests and notes

```
kubectl proxy --address='0.0.0.0' --port=8001 --accept-hosts='^*$'

kubectl get sa,role,rolebinding
kubectl auth can-i create deployment --as demO

```

## Easily get token of a serviceAccount
```
./2.dashboard.svcAcct_get_token.sh


./2.dashboard.svcAcct_get_token my-other-service-account

```



## Test

```
...

# Allow reading "pods" resources
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]

- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]
pods/log


# Allow all for "deployment" resources
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]


kubectl --token ${TOKEN-OF-SERVICEACCOUNT} get pods --all-namespaces

kubectl logs my-pod
```
