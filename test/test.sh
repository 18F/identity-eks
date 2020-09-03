#!/bin/sh
#
# This script sets up the environment variables so that terraform and
# the tests can know how to run and what to test.
#

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] ; then
	echo "usage:   $0 <cluster_name> <idp_hostname> <route53_zoneid>"
	echo "example: $0 eks-test secure.eks-test.foo.gov ZXXXXXXXX1234"
	exit 1
fi

export CLUSTER_NAME="$1"
export IDP_HOSTNAME="$2"
export TF_VAR_v2_zone_id="$3"
ACCOUNT=$(aws sts get-caller-identity | jq -r .Account)
export REGION="us-west-2"
export BUCKET="login-dot-gov-secops.${ACCOUNT}-${REGION}"

#go test -v -timeout 30m -run TestArgoClusterStatus
go test -v -timeout 30m

