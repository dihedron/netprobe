NAME := netcheck
DESCRIPTION := Simple probe to check network connectivity.
COPYRIGHT := 2024 © Andrea Funtò
LICENSE := MIT
LICENSE_URL := https://opensource.org/license/mit/
VERSION_MAJOR := 0
VERSION_MINOR := 0
VERSION_PATCH := 1

SHELL := /bin/bash

platforms="$$(go tool dist list)"
module := $$(grep "module .*" go.mod | sed 's/module //gi')
package := $(module)/version
now := $$(date --rfc-3339=seconds)

#
# Linux x86-64 build settings
#
linux/amd64: GOAMD64 = v3

#
# Windows x86-64 build settings
#
windows/amd64: GOAMD64 = v3


.PHONY: default
default: linux/amd64 ;

%:
	@go mod tidy
	@go generate ./...    
	@for platform in "$(platforms)"; do \
		if test "$(@)" = "$$platform"; then \
			echo "Building target $(@)..."; \
			mkdir -p dist/$(@); \
			GOOS=$(shell echo $(@) | cut -d "/" -f 1) GOARCH=$(shell echo $(@) | cut -d "/" -f 2) GOAMD64=$(GOAMD64) CGO_ENABLED=0 go build -v -ldflags="-X '$(package).Name=$(NAME)' -X '$(package).Description=$(DESCRIPTION)' -X '$(package).Copyright=$(COPYRIGHT)' -X '$(package).License=$(LICENSE)' -X '$(package).LicenseURL=$(LICENSE_URL)' -X '$(package).BuildTime=$(now)' -X '$(package).VersionMajor=$(VERSION_MAJOR)' -X '$(package).VersionMinor=$(VERSION_MINOR)' -X '$(package).VersionPatch=$(VERSION_PATCH)'" -o dist/$(@)/ .;\
			echo ...done!; \
		fi; \
	done

.PHONY: clean
clean:
	@rm -rf dist

.PHONY: install
install:
ifneq ($(shell id -u), 0)
	@echo "You must be root to perform this action."
else
	@cp dist/linux/amd64/netcheck /usr/local/bin
	@chmod 755 /usr/local/bin/netcheck
endif

.PHONY: uninstall
uninstall:
ifneq ($(shell id -u), 0)
	@echo "You must be root to perform this action."
else
	@rm -rf /usr/local/bin/netcheck
endif