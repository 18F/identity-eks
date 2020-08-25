#!/bin/sh

git clone https://github.com/aquasecurity/kube-bench.git
cd kube-bench
kubectl apply -f job.yaml
until [ ! -z "$POD" ] ; do
	POD=$(kubectl get pods | grep -E '^kube-bench.*Running' | awk '{print $1}')
done
kubectl logs -f "$POD"

cd ..
rm -rf kube-bench

