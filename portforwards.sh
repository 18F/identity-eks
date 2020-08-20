#!/bin/sh
#
# This script gets you access to All The Things.
#
# The only tricky bits are that the istioctl opens a url in
# whatever browser window you were last using, so maybe you
# will have to search to find that.
#
# Also, argocd's frontend code seems to be kinda flaky, so
# it benefits from being restarted sometimes, which is why
# it is not brackgrounded.  It might just need some more CPU
# or memory allocated to it.  Not sure.  Anyways, you can
# ^C it and restart it individually.
#

kubectl port-forward service/dashboard-kubernetes-dashboard 8444:443 -n kubernetes-dashboard &
kubectl port-forward service/prometheus 9090 -n istio-system &
kubectl port-forward service/grafana 3000 -n istio-system &
#kubectl port-forward service/kibana-kibana 5601 -n elk &
kubectl port-forward service/kibana-kb-http 5601 -n elastic-system &
istioctl dashboard kiali &
kubectl port-forward service/argocd-server 8443:443 -n argocd

