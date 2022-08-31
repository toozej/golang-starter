# Set sane defaults for Make from https://tech.davis-hansson.com/p/make/
SHELL = bash
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Set default goal such that `make` runs `make help`
.DEFAULT_GOAL := help

# Build info
BUILDER = $(shell whoami)@$(shell hostname)
NOW = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Version control
VERSION = $(shell git describe --tags --dirty --always)
COMMIT = $(shell git rev-parse --short HEAD)
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)

# Linker flags
PKG = $(shell head -n 1 go.mod | cut -c 8-)
VER = $(PKG)/version
LDFLAGS = -s -w \
	-X $(VER).Version=$(or $(VERSION),unknown) \
	-X $(VER).Commit=$(or $(COMMIT),unknown) \
	-X $(VER).Branch=$(or $(BRANCH),unknown) \
	-X $(VER).BuiltAt=$(NOW) \
	-X $(VER).Builder=$(BUILDER)

.PHONY: all vet test build run distroless-build distroless-run local-vet local-test local-run install pre-commit-install pre-commit-run pre-commit pre-reqs docs clean help

all: pre-commit vet clean test build run ## Run default workflow via Docker
local: pre-commit local-vet local-vendor clean local-test local-build local-run ## Run default workflow using locally installed Golang toolchain 
pre-reqs: pre-commit-install ## Install pre-commit hooks and necessary binaries

vet: ## Run `go vet` in Docker
	docker build --target vet -f $(CURDIR)/Dockerfile -t toozej/golang-starter:latest . 

test: ## Run `go test` in Docker
	docker build --target test -f $(CURDIR)/Dockerfile -t toozej/golang-starter:latest . 

build: ## Build Docker image, including running tests
	docker build -f $(CURDIR)/Dockerfile -t toozej/golang-starter:latest . 

run: ## Run built Docker image
	docker run --rm --name golang-starter -v $(CURDIR)/config:/config toozej/golang-starter:latest

distroless-build: ## Build Docker image using distroless as final base
	docker build -f $(CURDIR)/Dockerfile.distroless -t toozej/golang-starter:distroless . 

distroless-run: ## Run built Docker image using distroless as final base
	docker run --rm --name golang-starter -v $(CURDIR)/config:/config toozej/golang-starter:distroless

local-vet: ## Run `go vet` using locally installed golang toolchain
	go vet $(CURDIR)/cmd/golang-starter/*/

local-vendor: ## Run `go mod vendor` using locally installed golang toolchain
	go mod vendor

local-test: ## Run `go test` using locally installed golang toolchain
	go test $(CURDIR)/cmd/golang-starter/*/

local-build: ## Run `go build` using locally installed golang toolchain
	CGO_ENABLED=0 go build -ldflags="$(LDFLAGS)" $(CURDIR)/cmd/golang-starter/

local-run: ## Run locally built binary
	$(CURDIR)/golang-starter

install: local-build ## Install compiled binary to local machine
	sudo cp $(CURDIR)/golang-starter /usr/local/bin/golang-starter
	sudo chmod 0755 /usr/local/bin/golang-starter

pre-commit: pre-commit-install pre-commit-run ## Install and run pre-commit hooks

pre-commit-install: ## Install pre-commit hooks and necessary binaries
	# golangci-lint
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	# goimports
	go install golang.org/x/tools/cmd/goimports@latest
	# gosec
	go install github.com/securego/gosec/v2/cmd/gosec@latest
	# staticcheck
	go install honnef.co/go/tools/cmd/staticcheck@latest
	# go-critic
	go install github.com/go-critic/go-critic/cmd/gocritic@latest
	# structslop
	go install github.com/orijtech/structslop/cmd/structslop@latest
	# shellcheck
	sudo dnf install ShellCheck || sudo apt install shellcheck
	# install and update pre-commits
	pre-commit install
	pre-commit autoupdate

pre-commit-run: ## Run pre-commit hooks against all files
	pre-commit run --all-files

docs: ## Generate and serve documentation
	docker build -f $(CURDIR)/Dockerfile.docs -t toozej/golang-starter:docs . 
	docker run --rm --name golang-starter-docs -v $(CURDIR):/package -v $(CURDIR)/docs:/docs toozej/golang-starter:docs

docs-serve: ## Serve documentation on http://localhost:9000
	docker run --rm --name golang-starter-docs-serve -p 9000:3080 -v $(CURDIR)/docs:/data thomsch98/markserv 

clean: ## Remove any locally compiled binaries
	rm -f $(CURDIR)/golang-starter

help: ## Display help text
	@grep -E '^[a-zA-Z_-]+ ?:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
