source k3d.source
kubectl -n kube-system get services/traefik -o jsonpath="{.status.loadBalancer.ingress[*].ip}"
