# istio

This installs the istio profile.

You then can automatically inject istio by setting
```
metadata:
  labels:
    istio-injection: enabled
```
in a namespace to get everything injected in there, or add the
```
metadata
  annotations:
    sidecar.istio.io/inject: true
```
annotation to a deployment to do it on a more individual basis.

## Dashboard

`istioctl dashboard kiali`

# Caveats

This seems like a great way to wrap a thing with SSL and get all kinds of
cool metrics, but it isn't a cure-all.  For instance, elasticsearch doesn't
seem to work out of the box because it doesn't add pods to the routes, so
when nodes are trying to talk to elasticsearch-master-X, it ends up going
direct, which is not quite what you want.

For now, it appears as if istio is really only good at handling comms
to services, not between pods.  All the http-based services work great,
though!

