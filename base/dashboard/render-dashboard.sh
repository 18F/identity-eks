#!/bin/sh
#
# get the dashboard!
#
#curl https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml > dashboard.yaml

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

kubectl config set-context --current --namespace=kubernetes-dashboard
helm template dashboard kubernetes-dashboard/kubernetes-dashboard > dashboard.yaml

