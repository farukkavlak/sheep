GOLANGCI_LINT_VERSION := v2.13.2

BIN := $(CURDIR)/bin
LINT := $(BIN)/golangci-lint

.PHONY: build test lint fmt tools clean

build:
	go build -o $(BIN)/sheep-api ./cmd/sheep-api

test:
	go test -race ./...

lint: $(LINT)
	$(LINT) run

fmt: $(LINT)
	$(LINT) fmt

tools: $(LINT)

$(LINT):
	GOBIN=$(BIN) go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@$(GOLANGCI_LINT_VERSION)

clean:
	rm -rf $(BIN)
