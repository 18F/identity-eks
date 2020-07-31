#!/bin/sh

helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update

kubectl config set-context --current --namespace=kube-system
helm template metrics-server stable/metrics-server -f metrics-values.yml > metrics-server.yml

