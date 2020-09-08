#!/bin/sh

helm repo add halkeye https://halkeye.github.io/helm-charts/
helm repo update

helm template pdns halkeye/powerdns --version 0.2.0 > powerdns.yaml

