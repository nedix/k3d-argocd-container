ARG ALPINE_VERSION=3.21
ARG ARGOCD_VERSION=3.0.2
ARG HELM_VERSION=3.17.3
ARG K3S_VERSION=1.32.2
ARG KFILT_VERSION=0.0.8
ARG KUBECTL_VERSION=1.32.2
ARG KUSTOMIZE_VERSION=5.0.1
ARG S6_OVERLAY_VERSION=3.2.0.0

FROM alpine:${ALPINE_VERSION}

ARG ARGOCD_VERSION
ARG HELM_VERSION
ARG K3S_VERSION
ARG KFILT_VERSION
ARG KUBECTL_VERSION
ARG KUSTOMIZE_VERSION
ARG S6_OVERLAY_VERSION

RUN apk add --virtual .build-deps \
        bash \
        curl \
        xz \
    && apk add \
        docker-cli \
        docker-engine \
        fuse3 \
        git-daemon \
    && case "$(uname -m)" in \
        aarch64) \
            ARCHITECTURE="arm64" \
            S6_OVERLAY_ARCHITECTURE="aarch64" \
        ;; arm*) \
            ARCHITECTURE="arm64" \
            S6_OVERLAY_ARCHITECTURE="arm" \
        ;; x86_64) \
            ARCHITECTURE="amd64" \
            S6_OVERLAY_ARCHITECTURE="x86_64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
    | tar -xpJf- -C / \
    && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCHITECTURE}.tar.xz" \
    | tar -xpJf- -C / \
    && curl -fsSL "https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-${ARCHITECTURE}" \
        -o /usr/local/bin/argocd \
    && curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCHITECTURE}.tar.gz" \
    | tar xzOf - linux-${ARCHITECTURE}/helm > /usr/local/bin/helm \
    && curl -fsSL "https://github.com/ryane/kfilt/releases/download/v${KFILT_VERSION}/kfilt_${KFILT_VERSION}_linux_${ARCHITECTURE}" \
        -o /usr/local/bin/kfilt \
    && curl -fsSL https://dl.k8s.io/v${KUBECTL_VERSION}/kubernetes-client-linux-${ARCHITECTURE}.tar.gz \
    | tar xzOf - kubernetes/client/bin/kubectl > /usr/local/bin/kubectl \
    && curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCHITECTURE}.tar.gz" \
    | tar xzOf - kustomize > /usr/local/bin/kustomize \
    && chmod +x \
        /usr/local/bin/argocd \
        /usr/local/bin/helm \
        /usr/local/bin/kfilt \
        /usr/local/bin/kubectl \
        /usr/local/bin/kustomize \
    && apk del .build-deps

COPY /rootfs/ /

ENV ENV="/etc/profile"
ENV K3S_VERSION="$K3S_VERSION"

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK CMD kubectl get --raw="/readyz?verbose"

# HTTP
EXPOSE 80

# HTTPS
EXPOSE 443

# API
EXPOSE 6443

VOLUME /var/lib/docker
VOLUME /var/lib/kubelet
