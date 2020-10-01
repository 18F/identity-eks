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
     export TF_VAR_cluster_type="$2"
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
     istioctl
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

# XXX If you are migrating from an older version of the cluster, uncomment these, run the deploy, then comment them out.
# terraform import kubernetes_namespace.idp idp
# terraform import kubernetes_namespace.elk elk
# terraform import kubernetes_config_map.aws_auth kube-system/aws-auth
# terraform import kubernetes_config_map.idp-config idp/idp-config
# terraform import kubernetes_service.idp-redis idp/idp-redis
# terraform import kubernetes_ingress.idp-ingress istio-system/idp-ingress

# launch everything!
terraform apply

# This updates the kubeconfig so that we can access the cluster using kubectl
aws eks update-kubeconfig --name "$TF_VAR_cluster_name"
popd

# Seems like you need to turn on istio operator with istioctl to start it out?
if [ "$(kubectl -n istio-operator get deployment.apps/istio-operator -o json | jq .status.readyReplicas)" != "1" ] ; then
	echo "doing istioctl init to bootstrap istio"
	istioctl operator init
fi

# This turns on the EBS persistent volume stuff and make it the default.
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

# bootstrap argocd
kustomize build "$RUN_BASE/base/argocd" | kubectl apply -f -

# apply k8s config for this cluster by telling argo what to run.
if [ -z "$2" ] ; then
  kubectl apply -f "$RUN_BASE/cluster/cluster.yaml"
  #kustomize build "$RUN_BASE/cluster" | kubectl apply -f -
else
  kubectl apply -f "$RUN_BASE/cluster-$2/cluster.yaml"
  #kustomize build "$RUN_BASE/cluster-$2" | kubectl apply -f -
fi
