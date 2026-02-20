# Makefile to execute local build scripts

# Specify the shell to use (default is bash, but if your system uses dash instead)
SHELL := /bin/bash

# Define a default target that depends on both build_iso and convert_vmdk
all: build_iso convert_vmdk

# Target to run ./build_iso.sh
.PHONY: build_iso
build_iso:
	@echo "Running build_iso script..."
	./scripts/build_iso.sh || { echo "Error running build_iso.sh"; exit 1; }

# Target to run ./convert_vmdk.sh
.PHONY: convert_vmdk
convert_vmdk:
	@echo "Running convert_vmdk script..."
	./scripts/convert_vmdk.sh || { echo "Error running convert_vmdk.sh"; exit 1; }
