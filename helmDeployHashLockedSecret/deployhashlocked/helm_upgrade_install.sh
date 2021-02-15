kubectl create namespace deployhashlocked || true
export HELM_NAMESPACE=deployhashlocked
helm \
  upgrade --install --atomic --wait --timeout 3m \
  --reset-values \
  --debug \
  --namespace deployhashlocked \
  deployhashlocked \
  ./ \
  -f values.yaml \
&& \
kubectl -n deployhashlocked get deploy,pods,secret



#  --dry-run \


