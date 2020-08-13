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

