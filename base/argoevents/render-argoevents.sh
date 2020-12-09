#!/bin/sh

curl -s https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml > argoevents.yaml
curl -s https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml > eventbus/eventbus.yaml

