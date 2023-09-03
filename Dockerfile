FROM --platform=$BUILDPLATFORM ghcr.io/nedix/kubernetes-tools-docker:1.0.0 as tools

FROM ghcr.io/k3d-io/k3d:5.5.2-dind

RUN apk add \
        bash \
        git-daemon

COPY --link --from=tools /usr/local/bin/argocd /usr/local/bin/argocd
COPY --link --from=tools /usr/local/bin/helm /usr/local/bin/helm
COPY --link --from=tools /usr/local/bin/kfilt /usr/local/bin/kfilt
COPY --link --from=tools /usr/local/bin/kustomize /usr/local/bin/kustomize

COPY rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK CMD kubectl get --raw='/readyz?verbose'

EXPOSE 6445
