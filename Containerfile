ARG ARCHITECTURE
ARG ARGOCD_VERSION=2.13.1
ARG HELM_VERSION=3.16.3
ARG K3D_VERSION=5.7.4
ARG KFILT_VERSION=0.0.8
ARG KUSTOMIZE_VERSION=5.0.1

FROM ghcr.io/k3d-io/k3d:${K3D_VERSION}-dind

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
    && curl -fsSL https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-${ARCHITECTURE} -o /usr/local/bin/argocd \
    && curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCHITECTURE}.tar.gz \
    | tar xzOf - linux-${ARCHITECTURE}/helm > /usr/local/bin/helm \
    && curl -fsSL https://github.com/ryane/kfilt/releases/download/v${KFILT_VERSION}/kfilt_${KFILT_VERSION}_linux_${ARCHITECTURE} -o /usr/local/bin/kfilt \
    && curl -fsSL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCHITECTURE}.tar.gz \
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
