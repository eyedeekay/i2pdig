
UNAME ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
UARCH ?= $(shell uname -m | tr '[:upper:]' '[:lower:]' | sed 's|x86_64|amd64|g')

VERSION := 1.0

dummy:
	echo "$(UNAME) $(UARCH)"

deps:
	go get -u github.com/cryptix/goSam

install:
	install -m755 ./bin/i2pdig-$(UNAME)$(UARCH) /usr/bin/i2pdig

build: build-$(UNAME)

build-native:
	go get -u github.com/cryptix/goSam
	GOOS="$(UNAME)" GOARCH="$(UARCH)" go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig-"$(UNAME)$(UARCH)" \
		./i2pdig
	cp bin/i2pdig-"$(UNAME)$(UARCH)" bin/i2pdig

build-linux:
	GOOS=linux GOARCH="$(UARCH)" go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig-linuxamd64 \
		./i2pdig

build-linux-amd64:
	GOOS=linux GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig-linuxamd64 \
		./i2pdig

build-linux-arm:
	GOOS=linux GOARCH=arm go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig-linuxarm \
		./i2pdig

build-linux-mips:
	GOOS=linux GOARCH=mips go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig-linuxmips \
		./i2pdig

build-linux-mipsle:
	GOOS=linux GOARCH=mipsle go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig-linuxmipsle \
		./i2pdig

build-linux-mips64:
	GOOS=linux GOARCH=mips64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig-linuxmips64 \
		./i2pdig

build-linux-mips64le:
	GOOS=linux GOARCH=mips64le go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig-linuxmips64le \
		./i2pdig

build-linux-all: build-linux build-linux-arm build-linux-mips build-linux-mipsle build-linux-mips64 build-linux-mips64le

build-windows:
	GOOS=windows GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig.exe \
		./i2pdig

build-osx:
	GOOS=darwin GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig.bin \
		./i2pdig

build-consumeros-all: build-windows build-osx

build-freebsd:
	GOOS=freebsd GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig.freebsd \
		./i2pdig

build-dragonfly:
	GOOS=dragonfly GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig.dragonflybsd \
		./i2pdig

build-netbsd:
	GOOS=netbsd GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig.netbsd \
		./i2pdig

build-openbsd:
	GOOS=openbsd GOARCH=amd64 go build \
		-a \
		-tags netgo \
		-ldflags '-w -extldflags "-static"' \
		-o bin/i2pdig.openbsd \
		./i2pdig

build-bsd-all: build-freebsd build-dragonfly build-netbsd build-openbsd

all: build-linux-all build-consumeros-all build-bsd-all

checkinstall:
	rm -f ./bin/i2pdig_$(VERSION)-1_$(UARCH).deb
	checkinstall --install=no \
		--fstrans=yes \
		--default \
		--pkgname="i2pdig" \
		--pkgversion="$(VERSION)" \
		--arch="$(UARCH)" \
		--pkglicense=mit \
		--pkggroup=net \
		--pakdir=./bin/ \
		--nodoc \
		--strip=yes \
		--deldoc=yes \
		--deldesc=yes \
		--backup=no
	cp ./bin/i2pdig_$(VERSION)-1_$(UARCH).deb ../

release: gofmt all checkinstall

test: build-linux
	./bin/i2pdig -url=i2pforum.i2p

gofmt:
	gofmt -w i2pdig/*.go
