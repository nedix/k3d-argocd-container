CONTAINER := k8sage
DIND_VOLUME := k8sage

setup:
	@docker build --progress=plain -f Containerfile -t $(CONTAINER) $(CURDIR)
	@docker volume create $(DIND_VOLUME)
	@test -s applications.yml || cp applications.yml.example applications.yml

destroy:
	@$(MAKE) down
	@docker volume rm $(DIND_VOLUME) || true

up: ARGOCD_PORT = 443
up: KUBERNETES_PORT = 6445
up:
	@docker run --rm -d --name $(CONTAINER) \
		--privileged \
		--mount "type=bind,source=$(CURDIR)/applications.yml,target=/mnt/config/applications.yml" \
		-v $(CURDIR)/applications:/mnt/applications \
		-v $(DIND_VOLUME):/mnt/docker \
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
