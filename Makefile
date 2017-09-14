NAME = websocket-testing-api
REGISTRY =
VERSION = 1.0.0

TINI_VERSION = v0.14.0
GO_VERSION = 1.8.3

IMAGE_NAME = $(NAME):$(VERSION)
IMAGE_PATH = $(REGISTRY)/$(IMAGE_NAME)

GO_NAME = websockettestingapi
GO_BIN_NAME = websocket-testing-api

.PHONY: all compile build push clean

all: build

compile: clean
	mkdir -p build/bin
	cp -r src build
	docker run --rm \
	    -v /etc/passwd:/etc/passwd:ro \
	    -v $(CURDIR)/build:/build -w /build \
	    -e CGO_ENABLED=0 -e GOOS=linux -e GOARCH=amd64 \
	    -e GOPATH=/build \
	    -u $(shell id -u):$(shell id -g) \
	    golang:$(GO_VERSION) \
	        go build -v -a -pkgdir /build/pkg -installsuffix cgo -o bin/$(GO_BIN_NAME) $(GO_NAME)
	chmod +x build/bin/$(GO_BIN_NAME)

build: clean compile
	wget -O build/bin/tini https://github.com/krallin/tini/releases/download/$(TINI_VERSION)/tini-static

	chmod +x build/bin/tini
	docker build -t $(IMAGE_NAME) --rm .

push: build
	docker tag $(IMAGE_NAME) $(IMAGE_PATH)
	docker push $(IMAGE_PATH)

clean:
	rm -rf build
