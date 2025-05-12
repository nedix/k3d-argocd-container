CONTAINER := k8sage

setup:
	@docker build -f Containerfile -t $(CONTAINER) --progress=plain $(CURDIR)
	@-docker network create -d bridge k8sage
	@test -s applications.yml || cp applications.yml.example applications.yml

destroy:
	@$(MAKE) down
	@docker network rm k8sage

up: ARGO_CD_PORT = 8080
up: KUBERNETES_PORT = 6443
up:
	@docker run --rm -d --name $(CONTAINER) \
    	--privileged \
		--mount="type=bind,source=$(CURDIR)/applications.yml,target=/etc/k8sage/repositories/config/applications.yml" \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-p 127.0.0.1:$(ARGO_CD_PORT):80 \
		-p 127.0.0.1:$(KUBERNETES_PORT):6443 \
		k8sage
	@docker network connect k8sage $(CONTAINER)
	@docker logs -fn100 $(CONTAINER)
	@#while [ $$(docker ps -q -f "name=$(CONTAINER)" -f "health=healthy" | wc -l) -eq 0 ]; do sleep 1; done
#	@docker cp $(CONTAINER):kubeconfig.yml $(CURDIR)/config/kubeconfig.yml

down:
	@docker stop $(CONTAINER) || true
	@while [ $$(docker ps -q -f "name=$(CONTAINER)" -f "status=removing" | wc -l) -gt 0 ]; do sleep 1; done

shell:
	@docker exec -it $(CONTAINER) sh
