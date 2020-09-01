#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ] ; then
	echo "usage: $0 <clustername> <awsregion>"
	exit 1
fi

helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update

helm install eksclusterautoscaler autoscaler/cluster-autoscaler-chart --set autoDiscovery.clusterName="$1" --set awsRegion="$2" --set extraArgs.skip-nodes-with-system-pods="true"

