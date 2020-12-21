source k3d.source
LB_NAMESPACE=$(kubectl get service -A | grep LoadBalancer | head -1 | awk '{ print $1 }')
LB_SERVICE=$(kubectl get service -A | grep LoadBalancer | head -1 | awk '{ print $2 }')
kubectl -n $LB_NAMESPACE get service/$LB_SERVICE -o jsonpath="{.status.loadBalancer.ingress[*].ip}"
