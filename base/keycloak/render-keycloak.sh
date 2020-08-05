#!/bin/sh


helm repo add codecentric https://codecentric.github.io/helm-charts
helm repo update

kubectl config set-context --current --namespace=keycloak
helm template keycloak codecentric/keycloak -f keycloak-values.yaml > keycloak.yaml

