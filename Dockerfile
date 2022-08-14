# builder image
FROM golang:bullseye AS build

WORKDIR /go/golang-starter/

COPY README.md go.mod* go.sum* ./

# uncomment next line when there are Go Modules present
# RUN go get -d -v

COPY . ./
RUN go test ./*/
RUN go build

# runtime image
FROM scratch
# Copy our static executable.
COPY --from=build /go/golang-starter/golang-starter /go/bin/golang-starter
# Run the binary.
ENTRYPOINT ["/go/bin/golang-starter"]


