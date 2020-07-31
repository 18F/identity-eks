# Cluster Setup

This directory specifies what services should be running on this cluster.
This is the default cluster type, but you can specify other types when you are doing
your setup/deploy.  The config for those clusters are stored in `cluster-<type>`.
So you can have several flavors of clusters managed by this repo.  Like we might
have a `hub` cluster for doing terraform runs which will have a different set of
services, or a `secops` cluster that does other stuff.

## Configuration

The way the cluster is set up is the `deploy.sh` script runs something like
`kustomize build cluster | kubectl apply -f -`, so what gets started up here depends
on what you have in the `kustomize.yaml` file here.

Right now, it starts up[argocd](https://argoproj.github.io/argo-cd/),
then adds the contents of the `system` and `idp` directories.  Those directories, in turn,
have kustomize run on them and they roll on out too.  You can put plain yaml in there,
or even references to urls or git repos if you like, but ideally, everything
is started up using argocd 
[application.yaml files](https://argoproj.github.io/argo-cd/operator-manual/application.yaml)
so that argocd can manage updates and monitor status.

So to configure what gets started up here, you will want to add yaml and kustomize
configuration so that when `kustomize build .` runs, it generates the yaml that you
want to have running in the cluster.  Everything is nicely declarative this way.

## Kustomize

You should note that [Kustomize](https://kubernetes-sigs.github.io/kustomize/) is super
powerful, so you can do things like specify a branch at the top level kustomize.yaml,
and it can propagate it into all the other application manifests.  Or you can do the
same thing with an image name, or to pre or post-pend a string onto resource names,
like `dev-` or whatever.

Don't get too clever, lest ye make it difficult to follow, but know
that the tool is capable of many tricks.
