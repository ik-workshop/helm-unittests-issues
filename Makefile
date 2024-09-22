.EXPORT_ALL_VARIABLES:
.ONESHELL:
.DEFAULT_GOAL := help

# skopeo list-tags --no-creds docker://helmunittest/helm-unittest "3.13.3-0.4.1",
DOCKER_HELM_UNITITEST_IMAGE := helmunittest/helm-unittest:3.15.3-0.5.1
LOCAL_UNIT_TEST := $(HOME)/source/self/go-workshop/helm-unittest-tmp/untt

ISSUE := issue-413

SUPPORTED := chart \
  issue-156 \
	issue-268 \
	issue-275 \
	issue-254 \
	issue-212 \
	issue-221 \
	issue-183 \
	issue-227 \
	issue-286 \
	issue-288 \
	issue-294 \
	issue-303 \
	issue-312 \
	issue-316 \
	issue-329 \
	issue-340 \
	issue-403 \
	issue-412

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

unit-test-docker: ## Execute Unit tests via Container  -c "/bin/sh"
	$(info Running unit tests...)
	@docker run \
		-v $(shell pwd)/issue-400:/apps/\
		-it --rm  $(DOCKER_HELM_UNITITEST_IMAGE) --debug -f tests/*.yaml  .

# helm plugin install https://github.com/helm-unittest/helm-unittest.git
# helm plugin update unittest
unit-test-plugin: # Execute Unit tests locally with plugin
	$(info Running unit tests (upstream) for $(ISSUE)...)
	@helm unittest -f 'tests/*.yaml' --debugPlugin $(ISSUE)

unit-test-loop: check-issue ## Execute in the loop. 20 times
	@number=1 ; while [[ $$number -le 30 ]] ; do \
        $(MAKE) unit-test-plugin  ; \
				$(MAKE) unit-test-docker ; \
        ((number = number + 1)) ; \
  done

template: ## Helm template to validate
	$(info Running helm template for $(ISSUE)...)
	@helm template namespaces $(ISSUE) \
		--output-dir .output \
		--debug \
		--values $(ISSUE)/values.yaml

unit-test-local: ## Execute Unit tests with locally build (--debugPlugin)
	$(info Running unit tests for $(ISSUE)...)
	@$(LOCAL_UNIT_TEST) -f 'tests/*.yaml' --debugPlugin $(ISSUE)

unit-test-current: ## Execute Unit tests with locally build (--debugPlugin)
	@$(LOCAL_UNIT_TEST) -f 'tests/*.yaml' --coverage $(ISSUE)

test: unit-test-local ## Run all available tests
