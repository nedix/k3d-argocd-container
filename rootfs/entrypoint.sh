#!/usr/bin/env sh

: ${K3S_VERSION}

# -------------------------------------------------------------------------------
#    Liftoff!
# -------------------------------------------------------------------------------
exec env -i \
    API_PORT="$API_PORT" \
    HOME="/root" \
    HTTPS_PORT="$HTTPS_PORT" \
    HTTP_PORT="$HTTP_PORT" \
    K3S_VERSION="$K3S_VERSION" \
    KUBECONFIG="/root/.kube/config" \
    PATH="/usr/local/bin/:${PATH}" \
    S6_STAGE2_HOOK="/usr/sbin/s6-stage2-hook" \
    /init
