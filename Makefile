# forge-core Makefile

.PHONY: help install install-skills install-skills-claude install-skills-gemini install-skills-codex install-skills-opencode clean verify verify-skills verify-skills-claude verify-skills-gemini verify-skills-codex verify-skills-opencode test lint check lib-init

# Variables
SKILLS = BuildSkill BuildAgent BuildModule
SKILL_SRC = skills
LIB_DIR = $(or $(FORGE_LIB),lib)
SCOPE ?= workspace
CLAUDE_SKILLS_DST ?= $(if $(filter workspace,$(SCOPE)),$(CURDIR)/.claude/skills,$(HOME)/.claude/skills)
CODEX_SKILLS_DST ?= $(if $(filter workspace,$(SCOPE)),$(CURDIR)/.codex/skills,$(HOME)/.codex/skills)
OPENCODE_SKILLS_DST ?= $(if $(filter workspace,$(SCOPE)),$(CURDIR)/.opencode/skills,$(HOME)/.opencode/skills)

# Rust binaries from forge-lib submodule
INSTALL_SKILLS := $(LIB_DIR)/bin/install-skills
VALIDATE_MODULE := $(LIB_DIR)/bin/validate-module

help:
	@echo "forge-core management commands:"
	@echo "  make install                Install skills for all providers (SCOPE=workspace|user|all, default: workspace)"
	@echo "  make install-skills-claude  Install skills via SCOPE (workspace/user/all)"
	@echo "  make install-skills-gemini  Install skills via gemini CLI (uses SCOPE)"
	@echo "  make install-skills-codex   Install skills via SCOPE (workspace/user/all)"
	@echo "  make install-skills-opencode Install skills with kebab-case names via SCOPE"
	@echo "  make verify                 Verify the full installation"
	@echo "  make verify-skills          Verify skills for all providers"
	@echo "  make clean                  Remove previously installed skills"
	@echo "  make test                   Run module validation"
	@echo "  make lint                   Shellcheck all scripts"
	@echo "  make check                  Verify module structure"

# Ensure forge-lib submodule is initialized
lib-init:
	@if [ ! -f $(LIB_DIR)/Cargo.toml ]; then \
	  echo "Initializing forge-lib submodule..."; \
	  git submodule update --init $(LIB_DIR); \
	fi

# Ensure forge-lib binaries are built before install targets
$(INSTALL_SKILLS) $(VALIDATE_MODULE): lib-init
	@$(MAKE) -C $(LIB_DIR) build

install: install-skills
	@echo "Installation complete. Restart your session or reload skills."

install-skills: install-skills-claude install-skills-gemini install-skills-codex install-skills-opencode

install-skills-claude: $(INSTALL_SKILLS)
	@if [ "$(SCOPE)" = "all" ]; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider claude --scope "$(SCOPE)" --dst "$(CURDIR)/.claude/skills"; \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider claude --scope "$(SCOPE)" --dst "$(HOME)/.claude/skills"; \
	elif [ "$(SCOPE)" = "workspace" ]; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider claude --scope "$(SCOPE)" --dst "$(CURDIR)/.claude/skills"; \
	elif [ "$(SCOPE)" = "user" ]; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider claude --scope "$(SCOPE)" --dst "$(HOME)/.claude/skills"; \
	else \
	  echo "Error: Invalid SCOPE '$(SCOPE)'. Use workspace, user, or all."; \
	  exit 1; \
	fi

install-skills-gemini: $(INSTALL_SKILLS)
	@if command -v gemini >/dev/null 2>&1; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider gemini --scope "$(SCOPE)"; \
	else \
	  echo "  skip gemini skill install (gemini CLI not installed)"; \
	fi

install-skills-codex: $(INSTALL_SKILLS)
	@if [ "$(SCOPE)" = "all" ]; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider codex --scope "$(SCOPE)" --dst "$(CURDIR)/.codex/skills"; \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider codex --scope "$(SCOPE)" --dst "$(HOME)/.codex/skills"; \
	elif [ "$(SCOPE)" = "workspace" ]; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider codex --scope "$(SCOPE)" --dst "$(CURDIR)/.codex/skills"; \
	elif [ "$(SCOPE)" = "user" ]; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider codex --scope "$(SCOPE)" --dst "$(HOME)/.codex/skills"; \
	else \
	  echo "Error: Invalid SCOPE '$(SCOPE)'. Use workspace, user, or all."; \
	  exit 1; \
	fi

install-skills-opencode:
	@if [ "$(SCOPE)" = "all" ]; then \
	  dsts="$(CURDIR)/.opencode/skills $(HOME)/.opencode/skills"; \
	elif [ "$(SCOPE)" = "workspace" ]; then \
	  dsts="$(CURDIR)/.opencode/skills"; \
	elif [ "$(SCOPE)" = "user" ]; then \
	  dsts="$(HOME)/.opencode/skills"; \
	else \
	  echo "Error: Invalid SCOPE '$(SCOPE)'. Use workspace, user, or all."; \
	  exit 1; \
	fi; \
	for dst in $$dsts; do \
	  mkdir -p "$$dst"; \
	  for skill_dir in $(SKILL_SRC)/*/; do \
	    skill=$$(basename "$$skill_dir"); \
	    kebab=$$(echo "$$skill" | sed 's/\([A-Z]\)/-\1/g' | sed 's/^-//' | tr '[:upper:]' '[:lower:]'); \
	    mkdir -p "$$dst/$$kebab"; \
	    command cp "$$skill_dir"SKILL.md "$$dst/$$kebab/SKILL.md" 2>/dev/null || true; \
	    command cp "$$skill_dir"SKILL.yaml "$$dst/$$kebab/SKILL.yaml" 2>/dev/null || true; \
	  done; \
	  echo "  installed $$(ls -d "$$dst"/*/ 2>/dev/null | wc -l | tr -d ' ') skills to $$dst"; \
	done

clean:
	@for dir in .claude/skills .gemini/skills .codex/skills .opencode/skills; do \
	  for s in $(SKILLS); do \
	    command rm -rf "$$dir/$$s" 2>/dev/null || true; \
	  done; \
	done
	@echo "Cleaned installed skills."

verify: verify-skills

verify-skills: verify-skills-claude verify-skills-gemini verify-skills-codex verify-skills-opencode

verify-skills-claude:
	@missing=0; \
	if [ "$(SCOPE)" = "all" ]; then \
	  for dst in "$(CURDIR)/.claude/skills" "$(HOME)/.claude/skills"; do \
	    echo "Verifying Claude skills in $$dst..."; \
	    for s in $(SKILLS); do \
	      if test -f "$$dst/$$s/SKILL.md"; then \
	        echo "  ok $$s"; \
	      else \
	        echo "  missing $$s"; \
	        missing=1; \
	      fi; \
	    done; \
	  done; \
	else \
	  echo "Verifying Claude skills in $(CLAUDE_SKILLS_DST)..."; \
	  for s in $(SKILLS); do \
	    if test -f "$(CLAUDE_SKILLS_DST)/$$s/SKILL.md"; then \
	      echo "  ok $$s"; \
	    else \
	      echo "  missing $$s"; \
	      missing=1; \
	    fi; \
	  done; \
	fi; \
	test $$missing -eq 0

verify-skills-gemini:
	@if command -v gemini >/dev/null 2>&1; then \
	  echo "Verifying Gemini skills via CLI..."; \
	  out_file=$$(mktemp); \
	  if gemini skills list > "$$out_file" 2>&1; then \
	    grep -E "BuildSkill|BuildAgent|BuildModule" "$$out_file" || true; \
	  else \
	    echo "  skip gemini skill verification (non-interactive or unauthenticated)"; \
	  fi; \
	  command rm -f "$$out_file"; \
	else \
	  echo "  skip gemini skill verification (gemini CLI not installed)"; \
	fi

verify-skills-codex:
	@missing=0; \
	if [ "$(SCOPE)" = "all" ]; then \
	  for dst in "$(CURDIR)/.codex/skills" "$(HOME)/.codex/skills"; do \
	    echo "Verifying Codex skills in $$dst..."; \
	    for s in $(SKILLS); do \
	      if test -f "$$dst/$$s/SKILL.md"; then \
	        echo "  ok $$s"; \
	      else \
	        echo "  missing $$s"; \
	        missing=1; \
	      fi; \
	    done; \
	  done; \
	else \
	  echo "Verifying Codex skills in $(CODEX_SKILLS_DST)..."; \
	  for s in $(SKILLS); do \
	    if test -f "$(CODEX_SKILLS_DST)/$$s/SKILL.md"; then \
	      echo "  ok $$s"; \
	    else \
	      echo "  missing $$s"; \
	      missing=1; \
	    fi; \
	  done; \
	fi; \
	test $$missing -eq 0

verify-skills-opencode:
	@missing=0; \
	echo "Verifying OpenCode skills in $(OPENCODE_SKILLS_DST)..."; \
	for s in build-skill build-agent build-module; do \
	  if test -f "$(OPENCODE_SKILLS_DST)/$$s/SKILL.md"; then \
	    echo "  ok $$s"; \
	  else \
	    echo "  missing $$s"; \
	    missing=1; \
	  fi; \
	done; \
	test $$missing -eq 0

test: $(VALIDATE_MODULE)
	@$(VALIDATE_MODULE) $(CURDIR)

lint:
	@if find . -name '*.sh' -not -path '*/target/*' -not -path '*/lib/*' | grep -q .; then \
	  if ! command -v shellcheck >/dev/null 2>&1; then \
	    echo "shellcheck not installed (install with: brew install shellcheck)"; \
	    exit 1; \
	  fi; \
	  find . -name '*.sh' -not -path '*/target/*' -not -path '*/lib/*' -print0 | xargs -0 shellcheck -S warning; \
	fi

check:
	@test -f module.yaml && echo "  ok module.yaml" || echo "  MISSING module.yaml"
	@test -x "$(INSTALL_SKILLS)" && echo "  ok install-skills" || echo "  MISSING install-skills (run: make -C $(LIB_DIR) build)"
	@test -x "$(VALIDATE_MODULE)" && echo "  ok validate-module" || echo "  MISSING validate-module (run: make -C $(LIB_DIR) build)"
