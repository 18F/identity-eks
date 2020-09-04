#!/bin/sh
#
# This used to be done with https://github.com/pusher/k8s-spot-termination-handler,
# but this AWS supported one looks better:
# https://github.com/aws/aws-node-termination-handler
#

helm repo add eks https://aws.github.io/eks-charts
helm repo update

#helm template eks stable/k8s-spot-termination-handler --namespace kube-system > k8s-spot-termination-handler.yaml

helm template aws-node-termination-handler eks/aws-node-termination-handler \
  --namespace kube-system \
  --set enableSpotInterruptionDraining="true" \
  --set deleteLocalData="true" \
  --set jsonLogging="true" \
  --set enablePrometheusServer="true" > aws-node-termination-handler.yaml

