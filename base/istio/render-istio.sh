#!/bin/sh

VERSION="1.6.8"

curl -Ls "https://github.com/istio/istio/releases/download/$VERSION/istio-$VERSION-osx.tar.gz" > "istio-$VERSION-osx.tar.gz"
tar zxpf "istio-$VERSION-osx.tar.gz"

kubectl config set-context --current --namespace=istio-system
helm template  istio-base "istio-$VERSION/manifests/charts/base" > istio-base.yaml
helm template -n istio-system istio-16 "istio-$VERSION/manifests/charts/istio-control/istio-discovery" \
    -f "istio-$VERSION/manifests/charts/global.yaml" > istio-16.yaml

rm -rf "istio-$VERSION" "istio-$VERSION-osx.tar.gz"

