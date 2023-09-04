FROM --platform=$BUILDPLATFORM ghcr.io/nedix/kubernetes-tools-docker:1.0.3 as tools

FROM ghcr.io/k3d-io/k3d:5.5.2-dind

COPY --chown=nobody --from=tools /usr/local/bin/argocd /usr/local/bin/argocd
COPY --chown=nobody --from=tools /usr/local/bin/helm /usr/local/bin/helm
COPY --chown=nobody --from=tools /usr/local/bin/kfilt /usr/local/bin/kfilt
COPY --chown=nobody --from=tools /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --chown=nobody --from=tools /usr/local/bin/kustomize /usr/local/bin/kustomize

RUN apk add \
        bash \
        git-daemon

COPY rootfs/ /

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK CMD kubectl get --raw='/readyz?verbose'

EXPOSE 6445
