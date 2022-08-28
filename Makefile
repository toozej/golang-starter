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

.PHONY: all vet test build run distroless-build distroless-run local-vet local-test local-build local-run local-precommit docs clean 

all: local-precommit vet test build run clean
local: local-precommit local-vet local-vendor local-test local-build local-run

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

local-precommit:
	pre-commit install
	pre-commit run --all

docs:
	docker build -f $(CURDIR)/Dockerfile.docs -t toozej/golang-starter:docs . 
	docker run --rm --name golang-starter-docs -v $(CURDIR):/package -v $(CURDIR)/docs:/docs toozej/golang-starter:docs

docs-serve:
	docker run --rm --name golang-starter-docs-serve -p 9000:3080 -v $(CURDIR)/docs:/data thomsch98/markserv 

clean: 
	rm -f $(CURDIR)/golang-starter
