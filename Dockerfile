# setup project and deps
FROM golang:1.19-bullseye AS init

WORKDIR /go/golang-starter/

COPY go.mod* go.sum* ./
RUN go mod download

COPY . ./

FROM init as vet
RUN go vet ./cmd/golang-starter/*/ 

# run tests
FROM init as test
RUN go test ./cmd/golang-starter/*/

# build binary
FROM init as build
ARG LDFLAGS

RUN CGO_ENABLED=0 go build -ldflags="${LDFLAGS}" ./cmd/golang-starter/

# runtime image
FROM scratch
# Copy our static executable.
COPY --from=build /go/golang-starter/golang-starter /go/bin/golang-starter
# Run the binary.
ENTRYPOINT ["/go/bin/golang-starter"]
