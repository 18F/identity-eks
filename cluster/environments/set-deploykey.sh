#!/bin/sh
#
# This sets the deploy-key secret up in the terraform namespace so that
# deployments can use this read-only passwordless ssh key to check out source
# code from our private repos.
#

if [ ! -f "$1" ] && [ ! -f "$2" ]  ; then
  echo "usage:    $0 <id_rsa> <id_rsa.pub>"
  echo "example:  $0 ~/.ssh/deploy_id_rsa ~/.ssh/deploy_id_rsa.pub"
  exit 1
fi

CONFIGDIR="/tmp/deploy-key.$$/deploy-key"
mkdir -p "$CONFIGDIR"

cp "$1" "$CONFIGDIR"/id_rsa
cp "$2" "$CONFIGDIR"/id_rsa.pub
ssh-keyscan github.com > "$CONFIGDIR"/known_hosts


kubectl create secret generic deploy-key --from-file="$CONFIGDIR" -n terraform --dry-run=client -o yaml | kubectl apply -f -

rm -rf "$CONFIGDIR"
rmdir /tmp/deploy-key.$$

