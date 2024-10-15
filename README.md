# [k3d][K3D]-[argocd][Argo CD]-container a.k.a. k8sage

Kubernetes with Argo CD as a container. Can be used to test infrastructure code locally.

## Setup

### Summary

```shell
git clone https://github.com/argoproj/argocd-example-apps.git applications/example/
wget -qO- https://github.com/nedix/k3d-argocd-docker/archive/refs/heads/main.zip | tar xzOf - k3d-argocd-container-main/applications.yaml.example > applications.yaml
docker volume create k8sage
docker run --rm --pull always -d --name k8sage \
    -v k8sage:/mnt/docker \
    -v ${PWD}/applications:/mnt/applications \
    --mount "type=bind,source=${PWD}/applications.yaml,target=/mnt/config/applications.yaml" \
    -p 443:443 \
    -p 6445:6445 \
    --privileged \
    ghcr.io/nedix/k3d-argocd-docker
```

### Steps

**Mount a named volume for Docker in Docker cache**

```
docker volume create k8sage
```

Flags:

```
-v k8sage:/mnt/docker
```

**Mount your application repository on `/mnt/applications`**

```shell
git clone https://github.com/argoproj/argocd-example-apps.git applications/example/
```

Flags:

```
-v ${PWD}/applications:/mnt/applications
```

**Mount `applications.yaml` configuration file on `/mnt/config/applications.yaml`**

```shell
wget -qO- https://github.com/nedix/k3d-argocd-container/archive/refs/heads/main.zip | tar xzOf - k3d-argocd-docker-main/applications.yaml.example > applications.yaml
```

Flags:

```
--mount "type=bind,source=${PWD}/applications.yaml,target=/mnt/config/applications.yaml"
```

**Forward network ports**

Flags:

```
-p 443:443
```

```
-p 6445:6445
```

**Give privileges for Docker in Docker**

Flags:

```
--privileged
```

## Usage

### Argo CD GUI

[https://localhost:443](https://localhost:443)

Login: `admin:admin`

### Kubernetes API

Copy Kubernetes config to your host

```shell
docker cp k8sage:/etc/k8sage/cluster-config/kube/config.yaml ${PWD}/kubeconfig.yaml
```

Replace key `clusters.0.cluster.certificate-authority-data`

```yaml
insecure-skip-tls-verify: true
```

## Attribution

- [Argo CD] [(License)](https://raw.githubusercontent.com/argoproj/argo-cd/master/LICENSE)
- [Helm] [(License)](https://raw.githubusercontent.com/helm/helm/main/LICENSE)
- [K3D] [(License)](https://raw.githubusercontent.com/k3d-io/k3d/main/LICENSE)
- [Kfilt] [(License)](https://raw.githubusercontent.com/ryane/kfilt/main/LICENSE)
- [Kustomize] [(License)](https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/LICENSE)

[Argo CD]: https://github.com/argoproj/argo-cd
[Helm]: https://github.com/helm/helm
[K3D]: https://github.com/k3d-io/k3d
[Kfilt]: https://github.com/ryane/kfilt
[Kustomize]: https://github.com/kubernetes-sigs/kustomize
