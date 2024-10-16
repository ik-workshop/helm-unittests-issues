.EXPORT_ALL_VARIABLES:
.ONESHELL:
.DEFAULT_GOAL := help

# skopeo list-tags --no-creds docker://helmunittest/helm-unittest "3.13.3-0.4.1",
DOCKER_HELM_UNITITEST_IMAGE := helmunittest/helm-unittest:3.16.1-0.6.3
LOCAL_UNIT_TEST := $(HOME)/source/self/go-workshop/helm-unittest-tmp/untt

ISSUE := issue-457

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
	issue-300 \
	issue-303 \
	issue-312 \
	issue-316 \
	issue-329 \
	issue-340 \
	issue-403 \
	issue-412 \
	issue-413 \
	issue-426 \
	issue-429 \
	issue-431 \
	issue-x \
	issue-351 \
	issue-457

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

lint: ## Lint helm chart.
	helm lint chart --values chart/values.yaml --debug

unit-test-docker: ## Execute Unit tests via Container  -c "/bin/sh"
	$(info Running unit tests...)
	@docker run \
		-v $(shell pwd)/issue-400:/apps/\
		-it --rm  $(DOCKER_HELM_UNITITEST_IMAGE) --debug -f tests/*.yaml  .

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

deps: ## Helm dependencies
	@helm dependency build $(ISSUE)

# helm plugin install https://github.com/helm-unittest/helm-unittest.git
# helm plugin update unittest
unit-test-plugin: ## Execute Unit tests locally with plugin --debugPlugin
	$(info Running unit tests (upstream) for $(ISSUE)...)
	@helm unittest -f 'tests/*.yaml' $(ISSUE)

unit-test-local: ## Execute Unit tests with locally build (--debugPlugin)
	$(info Running unit tests for $(ISSUE)...)
	@$(LOCAL_UNIT_TEST) -f 'tests/*.yaml' --debugPlugin  $(ISSUE)

unit-test-current: ## Execute Unit tests with locally build (--debugPlugin)
	@$(LOCAL_UNIT_TEST) -f 'tests/*.yaml' --coverage $(ISSUE)

test: unit-test-local ## Run all available tests

test-chart:
	@$(LOCAL_UNIT_TEST) -f tests/parent_test.yaml $(ISSUE)

test-child-chart:
	@$(LOCAL_UNIT_TEST) -f tests/with-sub-chart_test.yaml $(ISSUE)

test-child-tests:
	@$(LOCAL_UNIT_TEST) -f tests/postgresql_deployment_test.yaml $(ISSUE)
