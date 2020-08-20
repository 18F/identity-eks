#!/bin/sh
#
# This requires the cluster name to be put in, so needs to be just run.
# No helm template fun here.  :-(
#

if [ -z "$1" ] ; then
	echo "usage $0 <clustername>"
	exit 1
fi

helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm repo update

kubectl config set-context --current --namespace=kube-system
helm install alb-ingress-controller incubator/aws-alb-ingress-controller \
  --set autoDiscoverAwsRegion=true \
  --set autoDiscoverAwsVpcID=true \
  --set clusterName="$1"

curl -s https://kubernetes-sigs.github.io/aws-alb-ingress-controller/examples/iam-policy.json > alb-ingress-controller-iam-policy.json

