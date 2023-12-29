#!/usr/bin/env bash

BACKGROUND_PIDS=()

is_first_boot() {
    test -e /mnt/docker/.first_boot && return 0 || return 1
}

run_in_background() {
    "$1" "${@:2}" 2>&1 &

    BACKGROUND_PIDS+=("$!")

    trap "kill -TERM ${BACKGROUND_PIDS[-1]} 2>/dev/null" TERM INT
}

kustomize_apply() {
    local KUSTOMIZE_DIR="$1"

    local TEMP_FILE=$(mktemp)
    trap 'rm -f "$TEMP_FILE"' EXIT

    kustomize build --enable-helm "$KUSTOMIZE_DIR" -o "$TEMP_FILE"

    kfilt -i kind=CustomResourceDefinition -f "$TEMP_FILE" | kubectl apply -f -
    kfilt -i kind=CustomResourceDefinition -f "$TEMP_FILE" | kubectl wait --for condition=established -f -
    kfilt -x kind=CustomResourceDefinition -f "$TEMP_FILE" | kubectl apply -f -
}

argocd() {
    command argocd --core "${@:1}"
}
