# [k3s-argocd-container](https://github.com/nedix/k3s-argocd-container) a.k.a. k8sage

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
wget -q https://github.com/nedix/k3s-argocd-container/applications.yml.example -O applications.yml
```

#### 4. Start the service

```shell
docker run --rm --pull always -d --name k8sage \
		-v /var/run/docker.sock:/var/run/docker.sock \
    -v ${PWD}/applications:/etc/k8sage/repositories/argocd-example-apps/ \
    --mount "type=bind,source=${PWD}/applications.yml,target=/var/k8sage/applications.yml" \
    nedix/k3s-argocd
```

#### 5a. Access the Argo CD GUI

- Navigate to [http://127.0.0.1](http://127.0.0.1)
- Optionally sign in with `admin:admin` as the credentials

#### 5b. Access the Kubernetes API

Copy Kubernetes config to your host

```shell
docker cp k8sage:/root/.kube/config ${PWD}/kubeconfig.yaml
```
