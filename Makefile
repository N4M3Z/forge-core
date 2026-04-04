# forge-core — build, test, lint, install

FORGE ?= forge

.PHONY: help build test lint check clean install verify

help:
	@echo "forge-core targets:"
	@echo "  make install   Deploy skills, agents, and rules to all providers"
	@echo "  make test      Validate module structure"
	@echo "  make lint      Check shell scripts and markdown"
	@echo "  make check     Verify prerequisites and module structure"
	@echo "  make verify    Validate module with forge-cli"
	@echo "  make clean     Remove build artifacts"

install:
	@command -v $(FORGE) >/dev/null 2>&1 || { echo "error: forge not found. Install forge-cli first: https://github.com/N4M3Z/forge-cli"; exit 1; }
	$(FORGE) install .

test:
	@command -v $(FORGE) >/dev/null 2>&1 || { echo "error: forge not found"; exit 1; }
	$(FORGE) validate .

lint:
	@if find . -name '*.sh' -not -path '*/build/*' | grep -q .; then \
	  find . -name '*.sh' -not -path '*/build/*' | xargs shellcheck -S warning 2>/dev/null || true; \
	fi

check:
	@command -v $(FORGE) >/dev/null 2>&1 && echo "  ok forge" || echo "  MISSING forge (https://github.com/N4M3Z/forge-cli)"
	@test -f module.yaml      && echo "  ok module.yaml"      || echo "  MISSING module.yaml"
	@test -f defaults.yaml    && echo "  ok defaults.yaml"    || echo "  MISSING defaults.yaml"
	@test -f README.md        && echo "  ok README.md"        || echo "  MISSING README.md"
	@test -f INSTALL.md       && echo "  ok INSTALL.md"       || echo "  MISSING INSTALL.md"
	@test -f LICENSE          && echo "  ok LICENSE"          || echo "  MISSING LICENSE"
	@test -f CONTRIBUTING.md  && echo "  ok CONTRIBUTING.md"  || echo "  MISSING CONTRIBUTING.md"
	@test -f CODEOWNERS       && echo "  ok CODEOWNERS"       || echo "  MISSING CODEOWNERS"

verify:
	@command -v $(FORGE) >/dev/null 2>&1 || { echo "error: forge not found"; exit 1; }
	$(FORGE) validate .

clean:
	rm -rf build/
