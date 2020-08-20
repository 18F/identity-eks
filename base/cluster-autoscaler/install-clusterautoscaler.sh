#!/bin/sh

if [ -z "$1" ] ; then
	echo "usage: $0 <clustername>"
	exit 1
fi

#helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update

helm install eks stable/cluster-autoscaler --set autoDiscovery.clusterName="$1"

