CONTAINER := k8sage
VOLUME := k8sage

setup:
	@docker build $(CURDIR) -t $(CONTAINER)
	@docker volume create $(VOLUME)
	@test -s config/applications.yaml || cp config/applications.yaml.example config/applications.yaml

destroy:
	@$(MAKE) down
	@docker volume rm $(VOLUME) || true

up: ARGOCD_PORT = 443
up: KUBERNETES_PORT = 6445
up:
	@docker run --rm -d --name $(CONTAINER) \
		--privileged \
		--mount "type=bind,source=$(CURDIR)/config/applications.yaml,target=/mnt/config/applications.yaml" \
		-v $(CURDIR)/config/applications:/mnt/applications \
		-v $(VOLUME):/mnt/docker \
		-p $(ARGOCD_PORT):443 \
		-p $(KUBERNETES_PORT):6445 \
		k8sage
	@docker logs -fn0 $(CONTAINER)
	@while [ $$(docker ps -q -f "name=$(CONTAINER)" -f "health=healthy" | wc -l) -eq 0 ]; do sleep 1; done
	@docker cp $(CONTAINER):/etc/k8sage/cluster-config/kube/config.yaml $(CURDIR)/output/kubeconfig.yaml

down:
	@docker stop -t=-1 $(CONTAINER) || true
	@while [ $$(docker ps -q -f "name=$(CONTAINER)" -f "status=removing" | wc -l) -gt 0 ]; do sleep 1; done

shell:
	@docker exec -it $(CONTAINER) bash
