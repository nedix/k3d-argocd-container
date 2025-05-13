setup:
	@docker build -f Containerfile -t k8sage --progress=plain $(CURDIR)
	@-docker network create -d bridge k8sage
	@test -s applications.yml || cp applications.yml.example applications.yml

destroy:
	@docker rm -fv k8sage k8sage-k3s
	@docker network rm k8sage

up: HTTP_PORT = 80
up: HTTPS_PORT = 443
up: API_PORT = 6443
up:
	@docker run --rm -d --name k8sage \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--mount="type=bind,source=$(CURDIR)/applications.yml,target=/etc/k8sage/repositories/config/applications.yml" \
		-e HTTP_PORT="$(HTTP_PORT)" \
		-e HTTPS_PORT="$(HTTPS_PORT)" \
		-e API_PORT="$(API_PORT)" \
		k8sage
	@docker network connect k8sage k8sage
	@docker logs -fn100 k8sage

down:
	@docker stop k8sage k8sage-k3s || true
	@while [ $$(docker ps -q -f "name=k8sage" -f "status=removing" | wc -l) -gt 0 ]; do sleep 1; done

shell:
	@docker exec -it k8sage sh
