ENV_FILE := .env
include ${ENV_FILE}
export $(shell sed 's/=.*//' ${ENV_FILE})
CURRENT_DIR = $(shell pwd)
ANSIBLE_RUNNER_IMAGE := quay.io/kameshsampath/rosa-fruits-app-ee

.PHONY:	buildee
buildee:
	@ansible-builder build --tag $(ANSIBLE_RUNNER_IMAGE) \
       --container-runtime docker