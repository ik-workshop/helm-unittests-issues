.EXPORT_ALL_VARIABLES:
.ONESHELL:
.DEFAULT_GOAL := help

# skopeo list-tags --no-creds docker://helmunittest/helm-unittest "3.13.3-0.4.1",
DOCKER_HELM_UNITITEST_IMAGE := helmunittest/helm-unittest:3.11.1-0.3.0
LOCAL_UNIT_TEST := $(HOME)/source/self/go-workshop/helm-unittest-tmp/untt

SUPPORTED := chart \
	issue-268 \
	issue-275 \
	issue-254 \
	issue-183 \
	issue-227 \
	issue-286 \
	issue-294 \
	issue-303

FILTER_FOLDER := $(filter $(folder),$(SUPPORTED))

.PHONY: help
help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: check-issue
check-issue: # export folder=chart
ifndef folder
	$(error The 'export folder=' variable is not set '$(SUPPORTED)'.)
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

update-plugin: ## Update plugin
	@helm plugin update unittest

template: ## Template helm chart for local testing.
	helm template chart $(folder) \
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

# helm plugin install https://github.com/helm-unittest/helm-unittest.git
unit-test-plugin: check-issue ## Execute Unit tests locally with plugin
	@helm unittest -f 'tests/*.yaml' --debug $(folder)

unit-test-loop: check-issue ## Execute in the loop. 20 times
	@number=1 ; while [[ $$number -le 30 ]] ; do \
        $(MAKE) unit-test-plugin  ; \
				$(MAKE) unit-test-docker ; \
        ((number = number + 1)) ; \
  done

unit-test-local: check-issue ## Execute Unit tests with locally build
	@$(LOCAL_UNIT_TEST) -f 'tests/*.yaml' --debugPlugin $(folder)

test: unit-test-local ## Run all available tests
