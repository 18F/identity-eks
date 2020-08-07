#!/bin/sh


helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

kubectl config set-context --current --namespace=consul
helm template consul hashicorp/consul -f consul-values.yaml > consul.yaml

