ENV_FILE := .env
include ${ENV_FILE}
export $(shell sed 's/=.*//' ${ENV_FILE})
CURRENT_DIR = $(shell pwd)

.PHONY:	buildee
buildee:
	@ansible-builder build -f $(BUILDER_EE_FILE) --tag $(ANSIBLE_RUNNER_IMAGE) \
       --container-runtime $(CONTAINER_RUNTIME)

.PHONY:	prechecks
prechecks:
ifeq ($(shell test -e $(KUBECONFIG) && echo "yes" ),yes)
	$(shell mkdir -p $(CURRENT_DIR)/.kube)
	$(shell cat $(KUBECONFIG) | tee $(CURRENT_DIR)/.kube/config > /dev/null )
else
	$(shell echo "Kubeconfig not found")
	exit 1;
endif

.PHONY: run
run:	prechecks
	@docker run -it  \
   -v $(CURRENT_DIR)/project:/runner/project:z \
   -v $(CURRENT_DIR)/bin:/runner/project/bin:z \
   -v $(CURRENT_DIR)/inventory:/runner/inventory:z \
   -v $(CURRENT_DIR)/env:/runner/env:z \
   -v $(CURRENT_DIR)/.kube:/home/runner/.kube:z \
   --env-file $(CURRENT_DIR)/.env \
   $(ANSIBLE_RUNNER_IMAGE) /runner/project/run.sh
