#!/bin/bash
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${__dir}" &&\
kubectl apply -f . &&\
kubecolor -n isample-httpfwd get all,ingress,gateway,virtualservice

