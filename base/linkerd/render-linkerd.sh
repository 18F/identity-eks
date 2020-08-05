#!/bin/sh


helm repo add linkerd https://helm.linkerd.io/stable
helm repo update

exp=$(date -v+8760H +"%Y-%m-%dT%H:%M:%SZ")
step certificate create identity.linkerd.cluster.local ca.crt ca.key --profile root-ca --no-password --insecure
step certificate create identity.linkerd.cluster.local issuer.crt issuer.key --ca ca.crt --ca-key ca.key --profile intermediate-ca --not-after 8760h --no-password --insecure

kubectl config set-context --current --namespace=linkerd
helm template linkerd2 \
  --set-file global.identityTrustAnchorsPEM=ca.crt \
  --set-file identity.issuer.tls.crtPEM=issuer.crt \
  --set-file identity.issuer.tls.keyPEM=issuer.key \
  --set identity.issuer.crtExpiry=$exp \
  linkerd/linkerd2 > linkerd.yaml

