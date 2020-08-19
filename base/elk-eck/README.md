# ECK

This is apparently the new way to install ELK, where the operator takes care
of everything, and you just tell it what to do.
* https://www.elastic.co/elastic-cloud-kubernetes
* https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html
* https://github.com/elastic/cloud-on-k8s

The `render-eck.sh` script will download the specified version of ECK into
`eck.yaml`.  Upgrades should be mostly as simple as upgrading the version
in there and rendering it and then checking it in and seeing it get deployed,
but there is an Upgrading section in the second link that probably has
more details.

## Upgrading elasticstack with ECK

XXX

## Using kibana

To access kibana, port forward 5601 to your host:
```
kubectl port-forward service/logging-kb-http 5601 -n elastic-system &
```

Then go to https://localhost:5601/ and log in with the `elastic` user and
the password that you can get by running this command:
```
kubectl get secret logging-es-elastic-user -o go-template='{{.data.elastic | base64decode}}' -n elastic-system ; echo
```

The default user is documented here:
https://www.elastic.co/guide/en/cloud-on-k8s/master/k8s-users-and-roles.html

