ENV ?= dev

.PHONY: help fmt validate test lint scan docs docs-check check init plan apply destroy

help: ## Show available targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-10s %s\n", $$1, $$2}'

fmt: ## Format all Terraform files
	terraform fmt -recursive

validate: ## Validate the stack and bootstrap without a backend
	terraform init -backend=false -input=false >/dev/null
	terraform validate
	cd bootstrap && terraform init -backend=false -input=false >/dev/null && terraform validate

test: ## Run tests against mocked AWS
	terraform test

lint: ## Run tflint on every module
	tflint --init
	tflint --recursive --config "$(CURDIR)/.tflint.hcl"

scan: ## Security scan with Trivy
	trivy config --severity MEDIUM,HIGH,CRITICAL --exit-code 1 .

docs: ## Regenerate module and root README tables
	terraform-docs --config .terraform-docs.yml .

docs-check: ## Fail if README tables are out of date
	terraform-docs --config .terraform-docs.yml --output-check .

check: fmt validate test lint scan docs-check ## Everything CI runs

init: ## Init the backend for ENV (dev, staging or prod)
	terraform init -reconfigure -backend-config=environments/$(ENV).s3.tfbackend

plan: ## Plan ENV
	terraform plan -var-file=environments/$(ENV).tfvars -out=$(ENV).tfplan

apply: ## Apply the saved plan for ENV
	terraform apply $(ENV).tfplan

destroy: ## Destroy ENV
	terraform destroy -var-file=environments/$(ENV).tfvars
