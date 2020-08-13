# istio

This installs the istio operator, as well as the default profile.

You then can automatically inject istio by setting
```
metadata:
  labels:
    environment: production
```
in a namespace to get everything injected in there, or add the
```
metadata
  annotations:
    sidecar.istio.io/inject: true
```
annotation to a deployment to do it on a more individual basis.

