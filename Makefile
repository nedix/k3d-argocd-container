setup:
	@docker build -f Containerfile -t k8sage --progress=plain $(CURDIR)
	@-docker network create -d bridge k8sage
	@test -s applications.yml || cp applications.yml.example applications.yml

destroy:
	@docker rm -fv k8sage k8sage-k3s
	@docker network rm k8sage

up: ARGO_CD_PORT = 8080
up: KUBERNETES_PORT = 6443
up:
	@docker run --rm -d --name k8sage \
    	--privileged \
		--mount="type=bind,source=$(CURDIR)/applications.yml,target=/etc/k8sage/repositories/config/applications.yml" \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-p 127.0.0.1:$(ARGO_CD_PORT):8080 \
		-p 127.0.0.1:$(KUBERNETES_PORT):6443 \
		k8sage
	@docker network connect k8sage k8sage
	@docker logs -fn100 k8sage

down:
	@docker stop k8sage k8sage-k3s || true
	@while [ $$(docker ps -q -f "name=k8sage" -f "status=removing" | wc -l) -gt 0 ]; do sleep 1; done

shell:
	@docker exec -it k8sage sh
