#!/bin/sh
#
# This script installs linkerd.  Normally, we would just render the
# helm template out and use the argocd-linkerd.yaml file to start it
# up in the cluster dir so that we automatically can roll out updates,
# but it puts the cert right in the rendered
# yaml, so we are just installing it by hand.
#
# There is some discussion about using certmanager for everything
# that may fix this up here:  https://github.com/linkerd/linkerd2/issues/3745
#

# Get the certmanager stuff and namespace stuff going.
# The certmanager stuff sets certmanager to automatically rotate
# certs.
kustomize build . | kubectl apply -f -

step certificate create identity.linkerd.cluster.local ca.crt ca.key --profile root-ca --no-password --insecure
kubectl create secret tls \
   linkerd-trust-anchor \
   --cert=ca.crt \
   --key=ca.key \
   --namespace=linkerd

helm repo add linkerd https://helm.linkerd.io/stable
helm repo update

# if there is an update that we want, we might need to nuke it and reinstall it.
# Otherwise, it is fine to try to reinstall it, because it will just say "nope".
helm install \
  linkerd2 \
  --set-file global.identityTrustAnchorsPEM=ca.crt \
  --set identity.issuer.scheme=kubernetes.io/tls \
  --set installNamespace=false \
  linkerd/linkerd2 \
  -n linkerd

# We don't need to store these.  If they get lost, then we can just
# put new ones in.
rm -f ca.crt ca.key

