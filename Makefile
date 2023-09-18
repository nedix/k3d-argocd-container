container := k8sage

setup:
	@test -s applications.yaml || cp applications.yaml.example applications.yaml
	@docker build $(CURDIR) -t $(container)
	@docker volume create $(container)

destroy:
	@$(MAKE) down
	@docker volume rm $(container) || true

fresh:
	@$(MAKE) destroy
	@$(MAKE) setup

up:
	@docker run --rm -d --name $(container) \
		--privileged \
		-p 6445:6445 \
		-v $(container):/mnt/docker \
		--mount type=bind,source="$(CURDIR)"/applications.yaml,target=/opt/k8sage/cluster-config/argo/applications.yaml \
		$(foreach application,$(wildcard applications/*/),-v $(CURDIR)/$(application):/mnt/$(application) ) \
		k8sage
	@$(MAKE) logs &
	@while [ $$(docker ps -q -f "name=$(container)" -f "health=healthy" | wc -l) -eq 0 ]; do sleep 1; done
	@docker cp $(container):/opt/k8sage/cluster-config/kube/config.yaml $(CURDIR)/kubeconfig.yaml

down:
	@docker stop -t=-1 $(container) || true
	@while [ $$(docker ps -q -f "name=$(container)" -f "status=removing" | wc -l) -gt 0 ]; do sleep 1; done

restart:
	@$(MAKE) down
	@$(MAKE) up

shell:
	@docker exec -it $(container) bash

logs:
	@docker logs -fn0 $(container)

link: dir :=
link: app :=
link:
	@$(eval app := $(shell basename "$(dir)"))
	@[[ -n "$(dir)" && -d "$(dir)" && "$${dir::1}" = "/" ]] || { echo "Invalid argument (dir): argument must be an absolute path to a directory."; exit 1; }
	@[[ ! "$(app)" =~ ^(k8sage|example)$$ ]] || { echo "Invalid argument (app): '$(app)' is a reserved application directory."; exit 1; }
	@ln -s "$(dir)" "$(CURDIR)/applications/$(app)"
	@$(MAKE) restart

unlink: app :=
unlink:
	@[[ ! "$(app)" =~ "/" ]] || { echo "Invalid argument (app): argument should not contain slashes."; exit 1; }
	@[[ ! "$(app)" =~ ^(k8sage|example)$$ ]] || { echo "Invalid argument (app): '$(app)' is a reserved application directory."; exit 1; }
	@rm -f "$(CURDIR)/applications/$(app)"
	@$(MAKE) restart
