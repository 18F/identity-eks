# EKS Infrastructure

This is where the login.gov devops and secops teams can collaborate on containerization,
security, and a potential new system for deploying our idp application.

## Architecture

### External Setup

Terraform is used to minimally set up EKS and create AWS resources.
Terraform is _capable_ of managing kubernetes resources, but doing so requires you to set up your
kubeconfig, which results in a sort of chicken and egg problem.  Many of the resources you would want
to manage also require translating your manifests into HCL, which seems like a pain to manage.
Thus, we encourage the use of terraform and AWS tooling to be confined as much as possible to managing
the external state of EKS.

Once the cluster is up, we are using kubernetes-native tooling to manage EKS.  If we do need
information from terraform, it is not too hard to create an output that generates yaml which we
can apply in the deploy script.  So you can create configmaps or secret manifests for use by the
applications that run in the cluster.

Other secrets and configuration are also being supplied externally.  It seems likely that we could
automate this with the deploy script and some s3 bucket work, but right now, the process for
doing this is undefined, though in some cases, there is a script that can be used to push
them in by hand.

### Internal Setup

The main internal setup that we do is run [Kustomize](https://kubernetes-sigs.github.io/kustomize/)
on a cluster directory.  What services are launched in a cluster depends entirely on the contents of
that directory.  In most cases, the only real thing that kustomize is doing is starting up
[ArgoCD](https://argoproj.github.io/argo-cd/) and supplying a bunch of application and project
manifests that argocd then uses to find all the system services and delegated application manifests
and start up.

Argocd can be configured with application and project manifests to look at particular repos, branches,
and filesystem locations for changes.  If they change, argocd will apply the changes.  It has a
GUI that lets you look at how it's set up and the status of the "sync" procedure.

System services should probably be started up under the argocd "default" project.  Applications that
are delegated to another group should probably have their own project created which limits what repos
they can pull from and what namespace(s) they can deploy to.  This allows the owners of that repo to
manage what is deployed.  This is a good way to allow the developers to manage rollouts themselves
without having to give them access to the rest of the cluster.

There is a lot of clever stuff you can do with argocd with "syncs" and "waves", but I think that it
might be better to leave that alone and focus on using [Flagger](https://github.com/weaveworks/flagger/)
for doing promotion.  It has the ability to do blue/green and canary deploys built in (canaries require
istio or some other service mesh to work though), and has really good support for doing tests and
monitoring of deploys as they are being promoted or rolled back.

### System Services

Once argocd is done launching everything, these things should be running:
* argocd:  The Continuous Delivery engine that deploys everything.  It has a pretty GUI, but can be run mostly hands-off too.
* falco:  A system that looks at system calls for dangerous behavior.
* clamav:  A tool that scans new files for malware.
* ELK:  A place where logs are collected and indexed, with an API and a pretty GUI frontend for searching.
* Applications:  Whatever applications the cluster is set up to run!

## How to set up a cluster

## How to make changes to a cluster

## Getting Logs

## Accessing pods

## Security
