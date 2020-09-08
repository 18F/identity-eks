#!/bin/sh

git clone https://github.com/cdwv/powerdns-helm

helm template pdns powerdns-helm > powerdns.yaml

rm -rf powerdns-helm

