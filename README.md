# golang-starter
Golang starter template

## changes required to use this as a starter template
- ensure new repo has the following GitHub Actions Secrets
	- GH_TOKEN
	- DOCKERHUB_USERNAME
	- DOCKERHUB_TOKEN
	- QUAY_USERNAME
	- QUAY_TOKEN
- find/replace module name to new repo name
	- file structure under cmd/$moduleName/
	- sed files
		- go.mod
		- main.go
		- Dockerfile
		- Makefile
