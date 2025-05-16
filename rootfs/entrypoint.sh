#!/usr/bin/env sh

: ${K3S_VERSION}

# -------------------------------------------------------------------------------
#    Liftoff!
# -------------------------------------------------------------------------------
exec env -i \
    HOME="/root" \
    K3S_VERSION="$K3S_VERSION" \
    KUBECONFIG="/root/.kube/config" \
    PATH="/usr/local/bin/:${PATH}" \
    S6_STAGE2_HOOK="/usr/sbin/s6-stage2-hook" \
    /init
