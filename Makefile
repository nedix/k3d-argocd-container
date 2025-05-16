setup:
	@test -s applications.yaml || cp applications.yaml.example applications.yaml
	@docker build -f Containerfile -t k8sage --progress=plain $(CURDIR)

destroy:
	@docker rm -fv k8sage

up: HTTP_PORT = 80
up: HTTPS_PORT = 443
up: API_PORT = 6443
up:
	@docker run --rm -d --name k8sage \
		--privileged \
		--cgroupns="host" \
		--mount="type=bind,source=$(CURDIR)/applications.yaml,target=/etc/k8sage/repositories/config/applications.yaml" \
		-p "127.0.0.1:$(HTTP_PORT):80" \
		-p "127.0.0.1:$(HTTPS_PORT):443" \
		-p "127.0.0.1:$(API_PORT):6443" \
		k8sage
	@{ \
		trap "kill $$LOG_PID" INT EXIT; \
		docker logs -f k8sage & \
		LOG_PID=$$!; \
		while [ $$(docker ps -q -f "name=k8sage" -f "health=healthy" | wc -l) -eq 0 ]; do sleep 1; done; \
		docker cp k8sage:/root/.kube/config $(CURDIR)/kubeconfig.yaml; \
		wait $$LOG_PID; \
	}

down:
	@docker stop k8sage || true
	@while [ $$(docker ps -q -f "name=k8sage" -f "status=removing" | wc -l) -gt 0 ]; do sleep 1; done

shell:
	@docker exec -it k8sage sh
