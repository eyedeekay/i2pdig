
dummy:

build-linux:
	go get -u github.com/cryptix/goSam
	GOOS=linux GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig \
		./src

build-linux-arm:
	go get -u github.com/cryptix/goSam
	GOOS=linux GOARCH=arm go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig \
		./src

build-windows:
	go get -u github.com/cryptix/goSam
	GOOS=windows GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig.exe \
		./src

build-osx:
	go get -u github.com/cryptix/goSam
	GOOS=darwin GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig.bin \
		./src

build-freebsd:
	go get -u github.com/cryptix/goSam
	GOOS=freebsd GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig.freebsd \
		./src

build-dragonfly:
	go get -u github.com/cryptix/goSam
	GOOS=dragonfly GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig.dragonflybsd \
		./src

build-netbsd:
	go get -u github.com/cryptix/goSam
	GOOS=netbsd GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig.netbsd \
		./src

build-openbsd:
	go get -u github.com/cryptix/goSam
	GOOS=openbsd GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig.openbsd \
		./src

build-linux-all: build-linux build-linux-arm

build-bsd-all: build-freebsd build-dragonfly build-netbsd build-openbsd

all: build-linux-all build-windows build-osx build-bsd-all

release: all

test: build-linux
	./bin/i2pdig -url=i2pforum.i2p

gofmt:
	gofmt -w src/*.go
