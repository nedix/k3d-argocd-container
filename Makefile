CONTAINER := k8sage
DOCKER_VOLUME := k8sage

setup:
	@docker build $(CURDIR) -t $(CONTAINER)
	@docker volume create $(DOCKER_VOLUME)
	@test -s applications.yaml || cp applications.yaml.example applications.yaml

destroy:
	@$(MAKE) down
	@docker volume rm $(DOCKER_VOLUME) || true

up: ARGOCD_PORT = 443
up: KUBERNETES_PORT = 6445
up:
	@docker run --rm -d --name $(CONTAINER) \
		--privileged \
		--mount "type=bind,source=$(CURDIR)/applications.yaml,target=/mnt/config/applications.yaml" \
		-v $(CURDIR)/applications:/mnt/applications \
		-v $(DOCKER_VOLUME):/mnt/docker \
		-p $(ARGOCD_PORT):443 \
		-p $(KUBERNETES_PORT):6445 \
		k8sage
	@docker logs -fn0 $(CONTAINER)
	@while [ $$(docker ps -q -f "name=$(CONTAINER)" -f "health=healthy" | wc -l) -eq 0 ]; do sleep 1; done
	@docker cp $(CONTAINER):/etc/k8sage/cluster-config/kube/config.yaml $(CURDIR)/kubeconfig.yaml

down:
	@docker stop -t=-1 $(CONTAINER) || true
	@while [ $$(docker ps -q -f "name=$(CONTAINER)" -f "status=removing" | wc -l) -gt 0 ]; do sleep 1; done

shell:
	@docker exec -it $(CONTAINER) bash
