FROM --platform=$BUILDPLATFORM ghcr.io/nedix/kubernetes-tools-docker:v2.0.1-scratch as tools

FROM ghcr.io/k3d-io/k3d:5.5.2-dind

COPY --chown=nobody --from=tools / /

RUN apk add \
        bash \
        git-daemon

COPY rootfs /

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK CMD kubectl get --raw='/readyz?verbose'

EXPOSE 6445
