# kube-bench CIS benchmark

This is where you can kick off a kube-bench run to see how
the cluster conforms to the Kubernetes CIS benchmark.

It comes from https://github.com/aquasecurity/kube-bench

The kustomize thing is a bit fragile becuase maybe they will get
rid of the ECR string that they have in there or change it.  I
don't quite understand why they aren't just using the main
repo, but maybe they expect that EKS people will only be able
to pull from ECR repos.

## CIS Benchmark Status

As of this writing (Tue Aug 25 13:27:02 PDT 2020), the only one that is other
than PASS is fixed in https://github.com/awslabs/amazon-eks-ami/pull/391 , which
has yet to be merged.

