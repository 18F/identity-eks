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
were going on in the cluster.

I'm not 100% sure, but I don't think that consul did any iptables/CNI
stuff to get connections into the proxy.  I think you needed to plug
those in by hand so that it would set some environment variables which
would let you discover that the services were living on the proxy,
ala https://unofficial-kubernetes.readthedocs.io/en/latest/concepts/services-networking/service/#discovering-services

