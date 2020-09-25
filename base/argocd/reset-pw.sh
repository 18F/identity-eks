#!/bin/sh

PW=$(htpasswd -bnBC 10 "" "$1" | tr -d ':\n')

kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "'$PW'",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

