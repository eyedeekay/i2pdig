
dummy:

build:
	go get -u github.com/cryptix/goSam
	GOOS=linux GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig \
		./src

test: build
	./bin/i2pdig -url=333.i2p

gofmt:
	gofmt -w src/*.go
