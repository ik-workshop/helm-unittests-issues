.EXPORT_ALL_VARIABLES:
.ONESHELL:
.DEFAULT_GOAL := help

# skopeo list-tags --no-creds docker://helmunittest/helm-unittest "3.13.3-0.4.1",
DOCKER_HELM_UNITITEST_IMAGE := helmunittest/helm-unittest:3.13.3-0.4.1
LOCAL_UNIT_TEST := $(HOME)/source/self/go-workshop/helm-unittest/untt

SUPPORTED := chart \
	issue-268 \
	issue-337 \
	issue-275 \
	issue-254 \
	issue-183

FILTER_FOLDER := $(filter $(folder),$(SUPPORTED))

.PHONY: help
help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: check-issue
check-issue: # export folder=chart
ifndef folder
	$(error The folder variable is not set '$(SUPPORTED)'.)
endif
ifeq ($(FILTER_FOLDER),)
		$(error $(folder) is not supported. Supported: '$(SUPPORTED)'.)
endif

hooks: ## install pre commit.
	@pre-commit install
	@pre-commit gc
	@pre-commit autoupdate

install: ## Install pre-commit hooks.
	@pre-commit install
	@pre-commit gc

uninstall: ## Uninstall hooks.
	@pre-commit uninstall

validate: ## Validate files with pre-commit hooks.
	@pre-commit run --all-files

cleanup:## Cleanup outputs
	@rm -rf output

template: ## Template helm chart for local testing.
	@helm template chart $(folder) \
		--output-dir output -n default \
		-f $(folder)/values.yaml \
		--debug

lint: ## Lint helm chart.
	helm lint chart --values chart/values.yaml --debug

unit-test-docker: check-issue ## Execute Unit tests via Container  -c "/bin/sh"
	$(info Running unit tests...)
	@docker run \
		-v $(shell pwd)/$(folder):/apps/\
		-it --rm  $(DOCKER_HELM_UNITITEST_IMAGE) --debug -f tests/*.yaml  .

unit-test-local: check-issue ## Execute Unit tests locally
	# @helm unittest -f 'tests/*.yaml' $(folder)
	@$(LOCAL_UNIT_TEST) -f 'tests/*.yaml' $(folder)

test: unit-test-local ## Run all available tests
