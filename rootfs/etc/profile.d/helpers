#!/usr/bin/env sh

kubectl config set-context --current --namespace=argo-cd

argocd() {
    command argocd --core "${@:1}"
}
