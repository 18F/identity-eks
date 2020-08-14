#!/bin/sh
#
# This requires the cluster name to be put in, so needs to be just run.
# No helm template fun here.  :-(
#

helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm repo update

CLUSTERNAME=$(kubectl config current-context | awk -F/ '{print $2}')

kubectl config set-context --current --namespace=kube-system
helm install alb-ingress-controller incubator/aws-alb-ingress-controller \
  --set autoDiscoverAwsRegion=true \
  --set autoDiscoverAwsVpcID=true \
  --set clusterName="$CLUSTERNAME"

curl -s https://kubernetes-sigs.github.io/aws-alb-ingress-controller/examples/iam-policy.json > alb-ingress-controller-iam-policy.json

