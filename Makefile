container := k8sage

setup:
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
		-v $(container):/mnt/k8sage \
		$(foreach application,$(wildcard applications/*/),-v $(CURDIR)/$(application):/mnt/$(application) ) \
		k8sage
	@$(MAKE) logs &
	@while [ $$(docker ps -q -f "name=$(container)" -f "health=healthy" | wc -l) -eq 0 ]; do sleep 1; done
	@docker cp $(container):/mnt/k8sage/kubeconfig.yaml $(CURDIR)/config/kubeconfig.yaml

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

link: dir =
link:
	@$(eval app=$(shell basename "$(dir)"))
	@[[ -n "$(dir)" && -d "$(dir)" && "$${dir::1}" = "/" ]] || { echo "Invalid argument: path must be an absolute path to a directory."; exit 1; }
	@[[ ! "$(app)" =~ ^(k8sage|example|example-multi)$$ ]] || { echo "Invalid argument: '$(app)' is a reserved application directory."; exit 1; }
	@ln -s "$(dir)" "$(CURDIR)/applications/$(app)"
	@$(MAKE) restart

unlink: app =
unlink:
	@[[ ! "$(app)" =~ "/" ]] || { echo "Invalid argument: application cannot contain slashes."; exit 1; }
	@[[ ! "$(app)" =~ ^(k8sage|example|example-multi)$$ ]] || { echo "Invalid argument: '$(app)' is a reserved application directory."; exit 1; }
	@rm -f "$(CURDIR)/applications/$(app)"
	@$(MAKE) restart
