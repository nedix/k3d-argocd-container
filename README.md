# [k3d-argocd-container](https://github.com/nedix/k3d-argocd-container) a.k.a. k8sage

Kubernetes with Argo CD inside a container.
Can be used to test infrastructure code locally.

## Usage

#### 1. Create a named volume for Docker in Docker

```
docker volume create k8sage
```

#### 2. Clone some example applications

```shell
git clone https://github.com/argoproj/argocd-example-apps.git applications/example/
```

#### 3. Create an `applications.yml` configuration file

```shell
wget -q https://github.com/nedix/k3d-argocd-container/applications.yml.example
```

#### 4. Start the service

```shell
docker run --rm --pull always -d --name k8sage \
    -v k8sage:/mnt/docker \
    -v ${PWD}/applications:/mnt/applications \
    --mount "type=bind,source=${PWD}/applications.yml,target=/mnt/config/applications.yml" \
    -p 443:443 \
    -p 6445:6445 \
    --privileged \ # required for docker-in-docker \
    nedix/k3d-argocd
```

#### 5a. Access the Argo CD GUI

- Navigate to [https://127.0.0.1:443](https://127.0.0.1:443)
- Sign in with `admin:admin` as the credentials

#### 5b. Access the Kubernetes API

Copy Kubernetes config to your host

```shell
docker cp k8sage:/etc/k8sage/cluster-config/kube/config.yaml ${PWD}/kubeconfig.yaml
```

Replace key `clusters.0.cluster.certificate-authority-data`

```yaml
insecure-skip-tls-verify: true
```

<hr>

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
