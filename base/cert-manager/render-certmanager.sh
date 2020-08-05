#!/bin/sh


helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl config set-context --current --namespace=cert-manager

helm template \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true > certmanager.yaml

