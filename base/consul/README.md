# Consul

https://www.consul.io/docs/k8s/connect/overview

## Pros

This works, and was really easy to do a simple install.  Doing
cert rotation seems possible, though their only story for that seems
to be vault.  It also had some REALLY nice ACL stuff to control
who could talk to who.

## Cons

However, the system seems to require you to configure a bunch of stuff by
hand in the manifests for things, like who they would be connecting to.
This is fine, until you realize that many things are connecting not to
services, but to particular hosts, like elasticsearch connects to
elasticsearch-master-X, where X varies depending on the number of
ES nodes you have.  So that stuff doesn't seem to be proxied.

What services are proxied seem to be configured through environment
variables like this:
```
ELASTICSEARCH_MASTER_SERVICE_PORT=9200
ELASTICSEARCH_MASTER_SERVICE_HOST=172.20.16.53
ELASTICSEARCH_MASTER_SERVICE_PORT_TRANSPORT=9300
ELASTICSEARCH_MASTER_SERVICE_PORT_HTTP=9200
```
(see https://unofficial-kubernetes.readthedocs.io/en/latest/concepts/services-networking/service/#discovering-services)

So if you are trying to go to the elasticsearch-master service,
cool, you get proxied.  But if you are going to elasticsearch-master-0,
you don't.

Contrast this to the way that linkerd uses iptables (or CNI, optionally)
to route stuff into the proxy.

Consul would never inject itself into anything running in kube-system, so
filebeat couldn't get automagically SSL-ized.

I couldn't find a way to see connection rates or how many connections
were going on in the cluster.

