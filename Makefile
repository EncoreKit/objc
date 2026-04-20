# =============================================================================
# Encore Obj-C SDK - Development Commands
# =============================================================================

SHELL := /bin/bash
.DEFAULT_GOAL := help

VERSION := $(shell awk '/^  s.version/ {gsub(/[^0-9.]/,""); print; exit}' EncoreObjC.podspec)

.PHONY: help
help:
	@echo "EncoreObjC — Objective-C overlay for the Encore iOS SDK"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Development:"
	@echo "  test                       Run Obj-C XCTest target"
	@echo "  lint                       Run pod lib lint"
	@echo ""
	@echo "Example App:"
	@echo "  setup-example              pod install in example/"
	@echo "  demo-ios                   Build example app for iOS (open in Xcode to run)"
	@echo "  clean-example              Remove build artifacts"
	@echo "  nuke                       Full clean: DerivedData + Pods + build dirs"
	@echo ""
	@echo "Release:"
	@echo "  sync-native-sdk            Bump EncoreKit pin if trunk has newer"
	@echo "  release                    Interactive release: bump version, tag, pod trunk push"
	@echo ""
	@echo "Current version: $(VERSION)"

.PHONY: test
test:
	@bash scripts/demo/run-tests.sh

.PHONY: lint
lint:
	@bash scripts/demo/lint.sh

.PHONY: setup-example
setup-example:
	@bash scripts/demo/setup-example.sh

.PHONY: demo-ios
demo-ios:
	@bash scripts/demo/demo-ios.sh

.PHONY: clean-example
clean-example:
	@bash scripts/demo/clean-example.sh

.PHONY: nuke
nuke:
	@bash scripts/demo/clean-example.sh --nuke

.PHONY: sync-native-sdk
sync-native-sdk:
	@bash scripts/release/sync-native-sdk.sh

.PHONY: release
release:
	@bash scripts/release/publish-release.sh
