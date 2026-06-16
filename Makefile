FORGE ?= forge

.PHONY: help install validate release clean

help:
	@echo "  make install    deploy content and activate hooks (git + jj)"
	@echo "  make validate   run all checks (commit + pre-push stages)"
	@echo "  make release    build release tarball"
	@echo "  make clean      remove build artifacts"

install:
	@command -v $(FORGE) >/dev/null 2>&1 \
	    || { echo "forge not found — ask an AI assistant to execute INSTALL.md"; exit 1; }
	git config core.hooksPath .githooks
	chmod +x .githooks/* 2>/dev/null || true
	$(FORGE) install --target ~
	@if [ -d .jj ] && command -v jj >/dev/null 2>&1; then \
	    jj config set --repo aliases.push "[\"util\",\"exec\",\"--\",\"bash\",\"$$PWD/.githooks/jj-push\"]"; \
	    echo "jj detected: 'jj push' runs the pre-push gate, then 'jj git push'"; \
	elif [ -d .jj ]; then \
	    echo "warn: .jj/ present but jj not on PATH — 'jj push' gate NOT wired"; \
	fi

validate:
	@bash .githooks/pre-commit
	@bash .githooks/pre-push

release:
	$(FORGE) release .

clean:
	rm -rf build/
