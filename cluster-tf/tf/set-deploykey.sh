#!/bin/sh
#
# This sets the deploy-key secret up in the terraform namespace so that
# deployments can use this read-only passwordless ssh key to check out source
# code from our private repos.
#

if [ ! -f "$1" ] || [ ! -f "$2" ]  ; then
  echo "usage:    $0 <id_rsa> <id_rsa_private>"
  echo "example:  $0 ~/.ssh/id_rsa ~/.ssh/id_rsa_private"
  echo "          where id_rsa and id_rsa.pub are the private/pub keys for the identity-devops repo"
  echo "          and id_rsa_private and id_rsa_private.pub are the private/pub keys for the identity-devops-private repo"
  exit 1
fi

CONFIGDIR="/tmp/deploy-key.$$/deploy-key"
mkdir -p "$CONFIGDIR"

cp "$1" "$CONFIGDIR"/id_rsa
cp "$1".pub "$CONFIGDIR"/id_rsa.pub
cp "$2" "$CONFIGDIR"/id_rsa_private
cp "$2".pub "$CONFIGDIR"/id_rsa_private.pub
ssh-keyscan github.com > "$CONFIGDIR"/known_hosts
cat > "$CONFIGDIR"/config <<EOF
Host *
    HashKnownHosts no
    StrictHostKeyChecking yes
    CheckHostIP no
EOF

kubectl create secret generic deploy-key --from-file="$CONFIGDIR" -n terraform --dry-run=client -o yaml | kubectl apply -f -

rm -rf "$CONFIGDIR"
rmdir /tmp/deploy-key.$$

