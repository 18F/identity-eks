#!/bin/sh

helm repo update

helm template eks stable/k8s-spot-termination-handler --namespace kube-system > k8s-spot-termination-handler.yaml

