#!/bin/sh

rm -rf kube-bench
git clone --quiet --depth 1 https://github.com/aquasecurity/kube-bench.git
kustomize build . | kubectl apply -f -

until [ ! -z "$JOB" ] ; do
	JOB=$(kubectl get job kube-bench | grep -E '^kube-bench.*1\/1')
	sleep 1
done

kubectl logs -f job.batch/kube-bench

kubectl delete job.batch/kube-bench
rm -rf kube-bench

