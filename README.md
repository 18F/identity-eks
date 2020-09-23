# EKS Infrastructure

This is where the login.gov devops and secops teams can collaborate on containerization,
security, and a potential new system for deploying our idp application.

If you want to learn how kubernetes works, a light, fun resource is: http://phippy.io/

## Architecture

### External Setup

Terraform is used to minimally set up EKS and create AWS resources.
Terraform is _capable_ of managing kubernetes resources, and we do so for a few resources,
but it seems like a good idea to minimize this.  Many of the resources you would want
to manage also require translating your manifests into HCL, which seems like a pain to manage.
Thus, we encourage the use of terraform and AWS tooling to be confined as much as possible to managing
the external state of EKS and the services we are creating for it.

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
* istio:  A system for wrapping all communication with SSL, doing access control, load shifting, request metrics, etc.
* flagger:  A system for doing acceptance tests and canary rollouts of new code
* Applications:  Whatever applications the cluster is set up to run!

## How to set up a cluster

To install a new cluster with the default cluster as described in the `cluster` directory deployed in it,
run `./setup.sh your-clustername`.

There are also a number of `cluster-*` directories which hold configuration for other kinds
of clusters.  To set up one of those, you can run `./setup.sh your-clustername clustertype`,
where `clustertype` is the suffix on the cluster dir that you want to apply.  Right now, the
clustertypes dirs are not kept up to date very well.  Most work has been focused on just playing
with the `cluster` directory.

Example:  `./setup.sh devops-test elk`

Once you have run setup.sh, you may need to wait for a minute or so for argocd to get deployed and then run
`./deploy.sh your-clustername` to make sure that everything is launched.

## How to make changes to a cluster

There are two kinds of changes:
* Changes to AWS/EKS setup/resources.
* Changes to the applications that are deployed in the cluster.

### AWS changes

We need to provision AWS resources, including an EKS cluster.  This is done with terraform, and
it lives in the terraform directory.  Add what you need there and then run
`./deploy.sh your-clustername`.

If you need to pass in information about the resources you just created to EKS, you ought
to be able to use the stuff in the `terraform/k8s.tf` file as an example on how to plug in
a configmap or a service into a namespace for deployments to use.

### Cluster Applications

When `./deploy.sh your-clustername` is run, it will make sure that argocd is running, and then
it will point it at the `cluster` or `cluster-<clustertype>` directory.

This means that you can use the powers of kustomize to configure all the things that get deployed
to the cluster.  So you can add plain old yaml manifests there if you like, but it is probably better if
you use argocd application manifests, because then you can just make changes to git, and argo will automatically
sync what is in git into the cluster, instead of you having to manually run the deploy script.
This is the ["app of apps"](https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#app-of-apps)
 model that lets you use waves to specify an order to deploy stuff and probably put some tests in
there too, though I've not used that aspect yet.

You can use helm in the application manifests too, but then you lose the ability to see what exactly is
being deployed.  I think it's better to use application manifests that point at git repos which contain
yaml that you want deployed, whether that yaml comes from `helm template` or is written by you.
That said, as time goes on, I am less resistant to just using helm sometimes.  It is basically another
form of package management, a concept that we know and trust in other contexts.

If you have changes to the applications pointed to by the argo manifests, you can just make
changes and check them in to git.  Once your changes are seen, argo will automatically deploy
your changes.

# Workflow

XXX This is a proposed flow.  Needs work.

* local development
* check code into dev branch:  CI runs
  * artifact is built
  * artifact is tested
  * artifact is scanned for security
  * artifact is promoted to the dev environment by CI checking the new tag into git
* The app will roll out into the dev environment, be tested, do migrations, etc.
* When developers are happy with this setup, they can PR their changes into master.
* When the PR has been approved and merged in, the app will do migrations, be
  tested, slowly rolled out, etc to the int and prod environments.

If you want to do more load testing or try something else out, just create a branch from prod
or dev or whatever and use kustomize's patch facility in the cluster dir of that branch to tell
argocd to pull from that branch instead of master, then run `./deploy.sh clustername`, do
your tests, then shut down the cluster once you are done to minimize cost.

# Operational tasks

## Getting Logs

You can use kibana with `kubectl port-forward service/kibana-kb-http 5601 -n elastic-system`, or you can
get a small buffer of logs by using `kubectl logs pod/<podname> -n <namespace>`.  You can find
the pod names with a command like `kubectl get pods -n <namespace>`.

## Accessing pods

If you need to get into a running service, you can find a pod that you like with
`kubectl get pods -n <namespace>`, and then use
`kubectl exec -it pod/<podname> -n <namespace> -- /bin/sh` to get into it.

You may need to add a container name after the pod name if you have sidecars going, like
if you have a service mesh running.

# Security

XXX

All by itself, containerization will make our security story much
better than what we have now.  Every process is running in it's own
LXC container, which provides fine-grained control over every aspect
of what the process in the container can do.  We are not yet sure
that we can pull this off, but we may be able to actually run all of
our customer-facing containers with read-only filesystems, which would
be a huge step forward.  In addition, we expect that every container
will be built, tested, and scanned for vulnerabilities well ahead of
when the container is rolled out.

We are using clamav for our compliance-mandated malware scanning. 
It generates a lot of noise right now, and needs to be tuned.

We are using falco to listen to the syscall behavior of our pods to detect
malicious behavior.  It also is noisy, and needs tuning and probably a
few canaries built into it.

We have an idea that twistlock would be a good thing to plug in as well,
thoug no work has been done on that yet.

Along with regular app logs and cloudtrail, we should have a tremendous
amount of visibility into the behavior of our system, from the IAAS level
down to syscalls.  All that remains is to decide what is important
and to alert on it.

# TODO
* figure out how to make database optional, so that we can deploy the `cluster-elk` type of cluster without a db.
* get email (SES) working
* get assets/external hostnames working (s3/cloudfront? short term might be to pass in lb name somehow and use that)
* DONE: get ACM or LE issuing certs
* DONE: figure out secrets strategy:  Use k8s secrets store, as etcd is now encrypted in EKS (https://github.com/aws/containers-roadmap/issues/263)
* Create system to prime secrets from s3 during bootstrap/update (right now, is sorta manual with script in idp repo)
* get outbound filtering going (https://monzo.com/blog/controlling-outbound-traffic-from-kubernetes https://github.com/monzo/egress-operator)
* DONE: get ALB ingress controller working instead of ELB?
* DONE: (use istio) figure out how to get idp using SSL (use alb ingress controller with a cert and back end ssl annotation, make istio ingress, done)
* get pivcac going (could we make this be on all hosts?)
* try to bug people into making config for the idp less crazy
* DONE:  get dashboard going so we can see how the cluster is doing with memory/CPU
* find automated way to upgrade cluster node images besides going to the console and clicking the button
* DONE: get ELK using SSL (using istio)
* get ELK importing from cloudtrail/cloudwatch
* set ELK up to perform well (own nodegroup with fast local storage? Or maybe just request io1 storage?  Maybe look at CPU limits too? Since we have PVs, we don't need to worry about resyncing anymore, though)
* get alerting going:  elastalert?  metrics from newrelic or prometheus?
* figure out if we really need an IDP for auth, or if we can use IAM roles with port forwarding or a cert-auth proxy instead (haven't found a hard requirement for IDP yet)
* PARTLY DONE: really look at the somewhat baroque terraform state stuff that was basically lifted from identity-devops and see if we can make it less ugly
* set up a "hub" cluster that manages the permanent clusters (basically, just set up IAM role and run deploy.sh)
* make sure we have a good node/cluster update strategy:  https://docs.aws.amazon.com/cli/latest/reference/eks/update-nodegroup-version.html and the cluster version in the tf code
* Figure out how to buff up CI pipeline so that it does container scanning and does builds/tests when the base images are updated, promote images to dev env automatically.
* DONE:  Get infrastructure tests going.  See `./test` for details.  More could be added.
* Figure out how to get kms correlation engine going:  send kms logs into cloudwatch?  Rework engine to slurp from ELK?
* make sure WAF is going on our services
* clean up clamav logging (no noise)
* dig into falco and make it's alerts useful to us (good canaries, no noise)
* get twistlock going in-cluster?
