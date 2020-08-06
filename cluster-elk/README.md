# ELK

This is where an ELK-only cluster is set up!
You can set one of these up by saying:
```
./setup.sh <yourclustername> elk
```
It should launch the cluster, do some setup, then
apply what is in this directory.

All of these manifests are rendered using kustomize and
applied to the cluster.  In most cases, this means that
argocd will be launching these services and doing deploys
when it sees changes in git, but it doesn't all have to be
managed by argo.

If you have changes to the cluster config (changes in this
`cluster-elk` directory or in the `terraform` directory),
you will need to run `./deploy.sh <yourclustername> elk`.
Changes to the code in the `base` directory shouldn't
require any `./deploy.sh` work, as they are automatically
rolled out as they appear in git.

