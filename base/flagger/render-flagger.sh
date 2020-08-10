#!/bin/sh

helm repo add flagger https://flagger.app
helm repo update

kubectl config set-context --current --namespace=linkerd
helm template flagger flagger/flagger \
    --namespace=linkerd \
    --set meshProvider=linkerd \
    --set metricsServer=http://linkerd-prometheus:9090 > flagger.yaml

curl -s https://raw.githubusercontent.com/weaveworks/flagger/master/artifacts/flagger/crd.yaml > flagger-crd.yaml

