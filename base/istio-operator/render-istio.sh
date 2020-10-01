#!/bin/sh

VERSION="1.7.2"

curl -Ls "https://github.com/istio/istio/releases/download/$VERSION/istio-$VERSION-osx.tar.gz" > "istio-$VERSION-osx.tar.gz"
tar zxpf "istio-$VERSION-osx.tar.gz"

cd "istio-$VERSION"
helm template istio-operator manifests/charts/istio-operator/ \
  --set hub=docker.io/istio \
  --set tag="$VERSION" \
  --set operatorNamespace=istio-operator \
  --set istioNamespace=istio-system > ../istio.yaml
cd ..

rm -rf "istio-$VERSION" "istio-$VERSION-osx.tar.gz"

