FROM --platform=$BUILDPLATFORM alpine:3.18 as build-env

ARG ARCHITECTURE

WORKDIR /build

RUN case `uname -m` in \
        aarch64) ARCHITECTURE=arm64; ;; \
        amd64) ARCHITECTURE=amd64; ;; \
        arm64) ARCHITECTURE=arm64; ;; \
        armv8b) ARCHITECTURE=arm64; ;; \
        armv8l) ARCHITECTURE=arm64; ;; \
        x86_64) ARCHITECTURE=amd64; ;; \
        *) echo "Unsupported architecture, exiting ..."; exit 1; ;; \
    esac \
    && echo "ARCHITECTURE=$ARCHITECTURE" > .env

FROM build-env as argocd

ARG ARGOCD_VERSION=2.8.2

RUN source .env \
    && apk add --virtual .build-deps \
        curl \
    && curl -sSL https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-${ARCHITECTURE} -o argocd \
    && chmod +x argocd \
    && apk del .build-deps

FROM build-env as helm

ARG HELM_VERSION=3.11.2

RUN source .env \
    && apk add --virtual .build-deps \
        curl \
    && curl -sLO https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCHITECTURE}.tar.gz \
    && tar xfO helm-v${HELM_VERSION}-linux-${ARCHITECTURE}.tar.gz linux-${ARCHITECTURE}/helm > helm \
    && chmod +x helm \
    && apk del .build-deps

FROM build-env as kfilt

ARG KFILT_VERSION=0.0.8

RUN source .env \
    && apk add --virtual .build-deps \
        curl \
    && curl -sSL https://github.com/ryane/kfilt/releases/download/v${KFILT_VERSION}/kfilt_${KFILT_VERSION}_linux_${ARCHITECTURE} -o kfilt \
    && chmod +x kfilt \
    && apk del .build-deps

FROM build-env as kustomize

ARG KUSTOMIZE_VERSION=5.0.1

RUN source .env \
    && apk add --virtual .build-deps \
        curl \
    && curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCHITECTURE}.tar.gz \
    && tar zxvf kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCHITECTURE}.tar.gz kustomize \
    && chmod +x kustomize \
    && apk del .build-deps

FROM ghcr.io/k3d-io/k3d:5.5.2-dind

RUN apk add \
        bash \
        git-daemon

COPY --link --from=argocd /build/argocd /usr/local/bin/argocd
COPY --link --from=helm /build/helm /usr/local/bin/helm
COPY --link --from=kfilt /build/kfilt /usr/local/bin/kfilt
COPY --link --from=kustomize /build/kustomize /usr/local/bin/kustomize

COPY rootfs/ /
COPY config/ /mnt/config/

RUN touch /first_boot

ENTRYPOINT ["/entrypoint.sh"]
