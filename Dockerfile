ARG ARCHITECTURE
ARG ARGOCD_VERSION=v2.11.3
ARG HELM_VERSION=v3.15.2
ARG K3D_VERSION=5.7.1-dind
ARG KFILT_VERSION=0.0.8
ARG KUSTOMIZE_VERSION=v5.0.1

FROM ghcr.io/k3d-io/k3d:${K3D_VERSION}

ARG ARCHITECTURE
ARG ARGOCD_VERSION
ARG HELM_VERSION
ARG KFILT_VERSION
ARG KUSTOMIZE_VERSION

RUN test -n "$ARCHITECTURE" || case $(uname -m) in \
        aarch64) ARCHITECTURE=arm64; ;; \
        amd64) ARCHITECTURE=amd64; ;; \
        arm64) ARCHITECTURE=arm64; ;; \
        armv8b) ARCHITECTURE=arm64; ;; \
        armv8l) ARCHITECTURE=arm64; ;; \
        x86_64) ARCHITECTURE=amd64; ;; \
        *) echo "Unsupported architecture, exiting..."; exit 1; ;; \
    esac \
    && apk add --virtual .build-deps \
        curl \
    && apk add \
        bash \
        git-daemon \
    && curl -fsSL https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-${ARCHITECTURE} -o /usr/local/bin/argocd \
    && curl -fsSL https://github.com/helm/helm/releases/download/v${HELM_VERSION}/helm-${HELM_VERSION}-linux-${ARCHITECTURE}.tar.gz \
    | tar xzOf - linux-${ARCHITECTURE}/helm > /usr/local/bin/helm \
    && curl -fsSL https://github.com/ryane/kfilt/releases/download/v${KFILT_VERSION}/kfilt_${KFILT_VERSION}_linux_${ARCHITECTURE} -o /usr/local/bin/kfilt \
    && curl -fsSL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCHITECTURE}.tar.gz \
    | tar xzOf - kustomize > /usr/local/bin/kustomize \
    && chmod +x \
        /usr/local/bin/argocd \
        /usr/local/bin/helm \
        /usr/local/bin/kfilt \
        /usr/local/bin/kustomize \
    && apk del .build-deps

COPY rootfs /

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK CMD kubectl get --raw='/readyz?verbose'

EXPOSE 443
EXPOSE 6445
