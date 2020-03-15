# vim: textwidth=0 wrapmargin=0

SHELL := /bin/bash
PWD = $(shell pwd)

PYTHON_OK := $(shell which python)
PYTHON_VERSION := $(shell python -V | cut -d' ' -f2)
PYTHON_REQUIRED := $(shell cat .python-version)

default: help

help: ## The help text you're reading
	@grep --no-filename -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

check_python: ## Check python installation
	@echo '*********** Checking for Python installation ***********'
    ifeq ('$(PYTHON_OK)','')
	    $(error python interpreter: 'python' not found!)
    else
	    @echo Found Python
    endif
	@echo '*********** Checking for Python version ***********'
    ifneq ('$(PYTHON_REQUIRED)','$(PYTHON_VERSION)')
	    $(error incorrect version of python found: '${PYTHON_VERSION}'. Expected '${PYTHON_REQUIRED}'!)
    else
	    @echo Found Python ${PYTHON_REQUIRED}
    endif
.PHONY: check_python

setup: check_python ## Setup virtualenv
	@echo '**************** Creating virtualenv *******************'
	pipenv run pip install --upgrade pip
	export PIPENV_DEFAULT_PYTHON_VERSION=${PYTHON_REQUIRED} PIPENV_VENV_IN_PROJECT=True && pipenv install --dev
	@echo '*************** Installation Complete ******************'
.PHONY: setup

check: setup ## Run the linting and security scanning tools
	@echo '**************** Check linting and security *******************'
	pipenv run bandit ./*
	pipenv run black --check .
	pipenv run ochrona
	pipenv run mypy .
	@echo '*************** Check Complete ******************'
.PHONY: setup

reset: ## Teardown tooling
	pipenv --rm
	rm -rf .mypy_cache
.PHONY: reset
