# golang-starter
Golang starter template

## changes required to use this as a starter template
- ensure new repo has the following GitHub Actions Secrets
	- GH_TOKEN
	- DOCKERHUB_USERNAME
	- DOCKERHUB_TOKEN
	- QUAY_USERNAME
	- QUAY_TOKEN
- find/replace golang-starter to new repo name
	- run `bash -c ./scripts/use_starter.sh $NEW_PROJECT_NAME_GOES_HERE`
	- to rename with a different GitHub username `bash -c ./scripts/use_starter.sh $NEW_PROJECT_NAME_GOES_HERE $GITHUB_USERNAME_GOES_HERE`

## changes required to update golang version
- run `bash -c ./scripts/update_golang_version.sh $NEW_VERSION_GOES_HERE`
