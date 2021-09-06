export POD_NAME=$(kubectl get pods --namespace default -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}") 
echo "In the end, open http://localhost:9090"
kubectl --namespace default port-forward $POD_NAME 9090 


