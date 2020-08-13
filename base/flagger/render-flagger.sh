#!/bin/sh

helm repo add flagger https://flagger.app
helm repo update

kubectl config set-context --current --namespace=istio-system
helm template flagger flagger/flagger \
    --namespace=istio-system \
    --set meshProvider=istio \
    --set metricsServer=http://prometheus:9090 > flagger.yaml

curl -s https://raw.githubusercontent.com/weaveworks/flagger/master/artifacts/flagger/crd.yaml > flagger-crd.yaml

