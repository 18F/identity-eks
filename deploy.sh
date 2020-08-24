#!/bin/sh
#
# This script does the initial setup for the environment.
# You should only run this once to get it going, then just use terraform apply
# after that.
# 
set -e

if [ -z "$1" ]; then
     echo "usage:  $0 <cluster_name> [<cluster_type>]"
     echo "example: ./deploy.sh secops-dev"
     echo "example: ./deploy.sh secops-dev dev"
     exit 1
else
     if [ -n "$2" ] ; then
        if [ ! -d "$2" ] ; then
          echo "cluster type not found: $2"
          exit 1
        fi
     fi
     export TF_VAR_cluster_name="$1"
fi

checkbinary() {
     if which "$1" >/dev/null ; then
          return 0
     else
          echo no "$1" found: exiting
          exit 1
     fi
}

REQUIREDBINARIES="
     terraform
     aws
     kubectl
     jq
     step
     kustomize
"
for i in ${REQUIREDBINARIES} ; do
     checkbinary "$i"
done


# some config
ACCOUNT=$(aws sts get-caller-identity | jq -r .Account)
REGION="us-west-2"
BUCKET="login-dot-gov-secops.${ACCOUNT}-${REGION}"
SCRIPT_BASE=$(dirname "$0")
RUN_BASE=$(pwd)


# clean up tfstate files so that we get them from the backend
find . -name terraform.tfstate -print0 | xargs -0 rm

# set it up with the s3 backend, push into the directory.
pushd "$SCRIPT_BASE/terraform"

terraform init -backend-config="bucket=$BUCKET" \
      -backend-config="key=tf-state/$TF_VAR_cluster_name" \
      -backend-config="dynamodb_table=secops_terraform_locks" \
      -backend-config="region=$REGION" \
      -upgrade
terraform apply

# This updates the kubeconfig so that the nodes can talk with the masters
# and also maps IAM roles to users.
aws eks update-kubeconfig --name "$TF_VAR_cluster_name"

# update the kubernetes services/configmaps using terraform data.
terraform output config_map_aws_auth | kubectl apply -f -
kubectl create namespace idp && true
terraform output idp_redis_service | kubectl apply -f - -n idp
terraform output idp_configmap | kubectl apply -f - -n idp
popd

# this turns on the EBS persistent volume stuff and make it the default
if kubectl describe sc ebs >/dev/null ; then
	echo ebs persistant storage already set up
else
	kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
	kubectl apply -f "$RUN_BASE/base/aws-ebs-csi-driver/ebs_storage_class.yml"
fi
if kubectl get sc | grep -E '^gp2.*default' >/dev/null ; then
    kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
    kubectl patch storageclass ebs -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
fi

# install linkerd
# XXX this has to be done here rather than as an application, since
# the linkerd helm chart puts the trust anchor key right in it, so we can't check
# it in.  Ideally, we have certmanager do this, and there is some discussion
# about this here: https://github.com/linkerd/linkerd2/issues/3745 but it is
# not yet happening.
#pushd "$RUN_BASE/base/linkerd/"
#./install-linkerd.sh
#popd

# install alb ingress controller
# XXX this has to be here because it needs to be run inline because it needs to know the
# name of the EKS cluster that it is deployed in.
pushd "$RUN_BASE/base/alb-ingress-controller/"
./install-albingress.sh "$TF_VAR_cluster_name" || true
popd
# XXX same with the cluster autoscaler
$RUN_BASE/base/cluster-autoscaler/install-clusterautoscaler.sh "$TF_VAR_cluster_name" || true


# bootstrap argocd
kustomize build "$RUN_BASE/base/argocd" | kubectl apply -f -

# apply k8s config for this cluster
if [ -z "$2" ] ; then
  kustomize build "$RUN_BASE/cluster" | kubectl apply -f -
else
  kustomize build "$RUN_BASE/cluster-$2" | kubectl apply -f -
fi

pushd "$SCRIPT_BASE/terraform"
sleep 5
terraform output idp_ingress | kubectl apply -f - -n istio-system
sleep 5
terraform output idp_gateway | kubectl apply -f - -n idp
popd
