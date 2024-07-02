ARG K3D_VERSION=5.6.3-dind
ARG TOOLS_VERSION=v0.67.0

FROM --platform=$BUILDPLATFORM ghcr.io/nedix/kubernetes-tools-docker:${TOOLS_VERSION} as tools

FROM ghcr.io/k3d-io/k3d:${K3D_VERSION}

COPY --chown=nobody --from=tools / /

RUN apk add \
        bash \
        git-daemon

COPY rootfs /

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK CMD kubectl get --raw='/readyz?verbose'

EXPOSE 6445
