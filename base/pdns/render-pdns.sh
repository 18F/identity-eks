#!/bin/sh

git clone https://github.com/cdwv/powerdns-helm.git

helm template pdns powerdns-helm --values pdns-values.yaml > pdns.yaml

rm -rf powerdns-helm

