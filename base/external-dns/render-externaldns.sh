#!/bin/sh

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm template external-dns bitnami/external-dns > external-dns.yaml

