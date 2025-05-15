# [k3s-argocd-container](https://github.com/nedix/k3s-argocd-container) a.k.a. k8sage

Kubernetes with Argo CD inside a container.
Can be used to test infrastructure code locally.

## Usage

#### 1. Create an `applications.yml` configuration file

```shell
wget -q https://github.com/nedix/k3s-argocd-container/applications.yml.example -O applications.yml
```

#### 2. Start the containers

```shell
docker run --rm --pull always -d --name k8sage \
		-v /var/run/docker.sock:/var/run/docker.sock \
    -v ${PWD}/applications:/etc/k8sage/repositories/argocd-example-apps/ \
		--mount="type=bind,source=${PWD}/applications.yml,target=/etc/k8sage/repositories/config/applications.yml" \
    nedix/k3s-argocd
```

#### 3a. Access the Argo CD GUI

- Navigate to [http://127.0.0.1](http://127.0.0.1)
- Optionally sign in with `admin:admin` as the credentials

#### 3b. Access the Kubernetes API

Copy Kubernetes config to your host

```shell
docker cp k8sage:/root/.kube/config ${PWD}/kubeconfig.yaml
```
