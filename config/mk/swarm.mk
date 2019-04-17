THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

-include $(THIS_DIR)/../swarm.env

PUBLIC_HOST ?= $(TARGET)-$(FACILITY).$(DOMAIN)
STACK = $(SERVICE)_$(FACILITY)_$(TARGET)

AWS_STORAGE_BUCKET_NAME ?= $(SERVICE)-$(FACILITY)-$(TARGET)
AWS_S3_CUSTOM_DOMAIN ?= $(TARGET)-$(FACILITY)-files.$(DOMAIN)

export

docker ?= docker

ifeq ( "$(shell test -e config/compose/$(TARGET).yml && echo y)","y")
deploy: A=-c config/compose/swarm.yml -c config/compose/$(TARGET).yml
else
deploy: A=-c config/compose/swarm.yml
endif

deploy undeploy stack-% service-%: DOCKER_HOST=$(SWARM_ADDR)

swarm-restore-db:
	docker service update $(STACK)_restoredb \
		--force --detach --replicas=1


swarm-refresh: build push undeploy sleep-20 deploy

build: dc-build
push: dc-push

refresh: undeploy sleep-20 deploy


deploy:
	$(docker) stack deploy -c docker-compose.yml $(A) $(STACK)

undeploy:
	-$(docker) stack rm $(A) $(STACK)
	
sleep-%:
	sleep $*


stack-%:
	$(docker) stack $* $(A)

logs:
	$(MAKE) logs-$(STACK) A=$(A)

logs-%:
	$(docker) service logs $(STACK)_$* $(A)

service-%:
	$(docker) service $* $(A)



	
		