container = k8sage

setup:
	@docker build . -t $(container)

up: bg =
up:
	@docker run --rm -i --name $(container) \
		--privileged \
		$(if $(bg),-d,) \
		-p 6445:6445 \
		-v $(CURDIR)/config/:/mnt/config/ \
		$(foreach application,$(wildcard applications/*/),-v $(CURDIR)/$(application):/mnt/$(application) ) \
		k8sage

down:
	@docker stop -t-1 $(container)
	@while [ $$(docker ps -f "name=$(container)" -f "status=removing" -q | wc -l) -gt 0 ]; do sleep 1; done

reload: bg =
reload:
	@docker exec $(container) k8sage stop
	@$(eval container_state="$(container)-state")
	@docker commit $(container) $(container_state)
	@$(MAKE) down
	@docker image tag $(container_state) $(container)
	@docker rmi $(container_state)
	@$(MAKE) up $(if $(bg),bg=yes,)

attach:
	@docker exec -it $(container) bash

logs:
	@docker logs --follow $(container)

link: dir =
link:
	@$(eval app=$(shell basename "$(dir)"))
	@[[ -n "$(dir)" && -d "$(dir)" && "$${dir::1}" = "/" ]] || { echo "Invalid argument: path must be an absolute path to a directory."; exit 1; }
	@[[ "$(app)" =~ ^(example|k8sage)$$ ]] && { echo "Invalid argument: '$(app)' is a reserved application directory."; exit 1; }
	@ln -s "$(dir)" "$(CURDIR)/applications/$(app)"

unlink: app =
unlink:
	@[[ "$(app)" =~ "/" ]] && { echo "Invalid argument: application cannot contain slashes."; exit 1; }
	@[[ "$(app)" =~ ^(example|k8sage)$$ ]] && { echo "Invalid argument: '$(app)' is a reserved application directory."; exit 1; }
	@rm -f "$(CURDIR)/applications/$(app)"
