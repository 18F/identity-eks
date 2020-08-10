# Consul

https://www.consul.io/docs/k8s/connect/overview

## Pros

This works, and was really easy to do a simple install.  Doing
cert rotation seems possible, though their only story for that seems
to be vault.  It also had some REALLY nice ACL stuff to control
who could talk to who.

## Cons

Consul would never inject itself into anything running in kube-system, so
filebeat couldn't get automagically SSL-ized.

I couldn't find a way to see connection rates or how many connections
were going on in the cluster.  Like there's no connection logging
facilities at all, it seems, though perhaps jaeger might do this.
It was not obvious how to get that going.

It appears as if it doesn't really discover all the services that are
being used in ELK, so it's not really able to wrap everything
automagically.  It will probably require some wacky kustomize variable
substitution kind of stuff to make this work.  For instance, if you
start it up and inject it, it will recognize these services
* elasticsearch
* elasticsearch-master-elk
* elasticsearch-master-headless-elk
* elasticsearch-sidecar-proxy
* kibana
* kibana-kibana-elk
* kibana-sidecar-proxy

But ES talks node to node on elasticsearch-master-X and does cluster
discovery using elasticsearch-master-headless.  So none of these services
are getting proxied.

