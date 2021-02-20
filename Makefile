SHELL := /bin/bash
PWD = $(shell pwd)

POETRY_OK := $(shell type -P poetry)
PYTHON_OK := $(shell type -P python)
PYTHON_VERSION ?= $(shell python -V | cut -d' ' -f2)
PYTHON_REQUIRED := $(shell cat .python-version)

default: help

help: ## The help text you're reading
	@grep --no-filename -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

check_python: ## Check build requirements
    ifeq ('$(PYTHON_OK)','')
	    $(error python interpreter: 'python' not found!)
    else
	    @echo Found Python.
    endif
    ifneq ('$(PYTHON_REQUIRED)','$(PYTHON_VERSION)')
	    $(error incorrect version of python found: '${PYTHON_VERSION}'. Expected '${PYTHON_REQUIRED}'!)
    else
	    @echo Correct Python version ${PYTHON_REQUIRED}.
    endif
    ifeq ('$(POETRY_OK)','')
	    $(error package 'poetry' not found!)
    else
	    @echo Found poetry
    endif
.PHONY: check_python

setup: check_python ## Setup virtualenv
	@echo '**************** Creating virtualenv *******************'
	export POETRY_VIRTUALENVS_IN_PROJECT=$(POETRY_VIRTUALENVS_IN_PROJECT) && poetry run pip install --upgrade pip
	poetry install --no-root
	@echo '*************** Installation Complete ******************'
.PHONY: setup

check: setup ## Run the linting and security scanning tools
	@echo '**************** Check linting and security *******************'
	poetry run bandit ./*
	poetry run black --check .
	poetry run ochrona
	poetry run mypy .
	@echo '*************** Check Complete ******************'
.PHONY: check

reformat: ## Run the black Python reformatter
	@echo '**************** Reformat code *******************'
	poetry run black .
	@echo '*************** Reformat Complete ******************'
.PHONY: reformat

reset: ## Teardown tooling
	rm -rfv .venv
.PHONY: reset
