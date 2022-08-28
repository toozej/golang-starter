SHELL = bash

# Build info.
BUILDER = $(shell whoami)@$(shell hostname)
NOW = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Version Control.
VERSION = $(shell git describe --tags --dirty --always)
COMMIT = $(shell git rev-parse --short HEAD)
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)

# Linker flags.
PKG = $(shell head -n 1 go.mod | cut -c 8-)
VER = $(PKG)/version
LDFLAGS = -s -w \
	-X $(VER).Version=$(or $(VERSION),unknown) \
	-X $(VER).Commit=$(or $(COMMIT),unknown) \
	-X $(VER).Branch=$(or $(BRANCH),unknown) \
	-X $(VER).BuiltAt=$(NOW) \
	-X $(VER).Builder=$(BUILDER)

.PHONY: all vet test build run distroless-build distroless-run local-vet local-test local-build local-run pre-commit-install pre-commit-run pre-commit pre-reqs docs clean

all: pre-commit vet test build run clean
local: pre-commit local-vet local-vendor local-test local-build local-run
pre-reqs: pre-commit-install

vet:
	docker build --target vet -f $(CURDIR)/Dockerfile -t toozej/golang-starter:latest . 

test:
	docker build --target test -f $(CURDIR)/Dockerfile -t toozej/golang-starter:latest . 

build:
	docker build -f $(CURDIR)/Dockerfile -t toozej/golang-starter:latest . 

run:
	docker run --rm --name golang-starter -v $(CURDIR)/config:/config toozej/golang-starter:latest

distroless-build:
	docker build -f $(CURDIR)/Dockerfile.distroless -t toozej/golang-starter:distroless . 

distroless-run:
	docker run --rm --name golang-starter -v $(CURDIR)/config:/config toozej/golang-starter:distroless

local-vet:
	go vet $(CURDIR)/cmd/golang-starter/*/

local-vendor:
	go mod vendor

local-test:
	go test $(CURDIR)/cmd/golang-starter/*/

local-build:
	CGO_ENABLED=0 go build -ldflags="$(LDFLAGS)" $(CURDIR)/cmd/golang-starter/

local-run: 
	$(CURDIR)/golang-starter

pre-commit: pre-commit-install pre-commit-run

pre-commit-install:
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
	# install and update pre-commits
	pre-commit install
	pre-commit autoupdate

pre-commit-run:
	pre-commit run --all-files

docs:
	docker build -f $(CURDIR)/Dockerfile.docs -t toozej/golang-starter:docs . 
	docker run --rm --name golang-starter-docs -v $(CURDIR):/package -v $(CURDIR)/docs:/docs toozej/golang-starter:docs

docs-serve:
	docker run --rm --name golang-starter-docs-serve -p 9000:3080 -v $(CURDIR)/docs:/data thomsch98/markserv 

clean: 
	rm -f $(CURDIR)/golang-starter
