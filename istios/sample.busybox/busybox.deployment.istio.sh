#!/bin/bash
#kubectl apply -f <(./istioctl kube-inject -f manifests/one-files/busybox.deployment.istio.yaml )
kubectl -n istio-theater apply -f busybox.deployment.istio.yaml
