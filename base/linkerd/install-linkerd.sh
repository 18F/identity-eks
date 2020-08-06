#!/bin/sh

kubectl create namespace linkerd

if [ ! -f ca.key ] ; then
  step certificate create identity.linkerd.cluster.local ca.crt ca.key \
     --profile root-ca --no-password --insecure && \
   kubectl create secret tls \
     linkerd-trust-anchor \
     --cert=ca.crt \
     --key=ca.key \
     --namespace=linkerd
fi

