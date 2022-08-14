.PHONY: all test build run clean

all: test build run clean

test:
	docker build --target test -f $(CURDIR)/Dockerfile -t toozej/golang-starter:latest . 

build:
	docker build -f $(CURDIR)/Dockerfile -t toozej/golang-starter:latest . 

run: 
	docker run --rm --name golang-starter -v $(CURDIR)/config:/config toozej/golang-starter:latest

clean: 
	rm -f $(CURDIR)/golang-starter
