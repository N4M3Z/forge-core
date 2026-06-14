## Compatibility & Portability

- Use `#!/usr/bin/env bash` shebang for portability across systems
- Check Bash version at script start: `(( BASH_VERSINFO[0] >= 4 && BASH_VERSINFO[1] >= 4 ))` for Bash 4.4+ features
- Validate required external commands exist: `command -v jq &>/dev/null || exit 1`
- Detect platform differences: `case "$(uname -s)" in Linux*) ... ;; Darwin*) ... ;; esac`
- Handle GNU vs BSD tool differences (e.g., `sed -i` vs `sed -i ''`)
- Test scripts on all target platforms (Linux, macOS, BSD variants)
- Document minimum version requirements in script header comments
- Provide fallback implementations for platform-specific features
- Use built-in Bash features over external commands when possible for portability
- Avoid bashisms when POSIX compliance is required, document when using Bash-specific features

## Modern Bash Features (5.x)

- **Bash 5.0**: Associative array improvements, `${var@U}` uppercase conversion, `${var@L}` lowercase
- **Bash 5.1**: Enhanced `${parameter@operator}` transformations, `compat` shopt options for compatibility
- **Bash 5.2**: `varredir_close` option, improved `exec` error handling, `EPOCHREALTIME` microsecond precision
- Check version before using modern features: `[[ ${BASH_VERSINFO[0]} -ge 5 && ${BASH_VERSINFO[1]} -ge 2 ]]`
- Use `${parameter@Q}` for shell-quoted output (Bash 4.4+)
- Use `${parameter@E}` for escape sequence expansion (Bash 4.4+)
- Use `${parameter@P}` for prompt expansion (Bash 4.4+)
- Use `${parameter@A}` for assignment format (Bash 4.4+)
- Employ `wait -n` to wait for any background job (Bash 4.3+)
- Use `mapfile -d delim` for custom delimiters (Bash 4.4+)

## CI/CD Integration

- **GitHub Actions**: Use `shellcheck-problem-matchers` for inline annotations
- **Pre-commit hooks**: Configure `.pre-commit-config.yaml` with `shellcheck`, `shfmt`, `checkbashisms`
- **Actionlint**: Validate GitHub Actions workflow files that use shell scripts

## Essential Tools

### Static Analysis & Formatting
- **ShellCheck**: Static analyzer with `enable=all` and `external-sources=true` configuration
- **shfmt**: Shell script formatter with standard config (`-i 4 -ci -bn -sr -kp`)
- **checkbashisms**: Detect bash-specific constructs for portability analysis
- **Semgrep**: SAST with custom rules for shell-specific security issues
- **CodeQL**: GitHub's security scanning for shell scripts

### Testing Frameworks
- **bats-core**: Maintained fork of Bats with modern features and active development
- **shellspec**: BDD-style testing framework with rich assertions and mocking
- **shunit2**: xUnit-style testing framework for shell scripts
- **bashing**: Testing framework with mocking support and test isolation

### Modern Development Tools
- **bashly**: CLI framework generator for building command-line applications
- **basher**: Bash package manager for dependency management
- **bpkg**: Alternative bash package manager with npm-like interface
- **shdoc**: Generate markdown documentation from shell script comments
- **shellman**: Generate man pages from shell scripts

### CI/CD & Automation
- **pre-commit**: Multi-language pre-commit hook framework
- **actionlint**: GitHub Actions workflow linter
- **gitleaks**: Secrets scanning to prevent credential leaks
- **Makefile**: Automation for lint, format, test, and release workflows

## References & Further Reading

### Style Guides & Best Practices
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) - Comprehensive style guide covering quoting, arrays, and when to use shell
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls) - Catalog of common Bash mistakes and how to avoid them
- [Bash Hackers Wiki](https://flokoe.github.io/bash-hackers-wiki/) - Comprehensive Bash documentation and advanced techniques
- [Defensive BASH Programming](https://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/) - Modern defensive programming patterns

### Tools & Frameworks
- [ShellCheck](https://github.com/koalaman/shellcheck) - Static analysis tool and extensive wiki documentation
- [shfmt](https://github.com/mvdan/sh) - Shell script formatter with detailed flag documentation
- [bats-core](https://github.com/bats-core/bats-core) - Maintained Bash testing framework
- [shellspec](https://github.com/shellspec/shellspec) - BDD-style testing framework for shell scripts
- [bashly](https://bashly.dannyb.co/) - Modern Bash CLI framework generator
- [shdoc](https://github.com/reconquest/shdoc) - Documentation generator for shell scripts

### Security & Advanced Topics
- [Awesome Bash](https://github.com/awesome-lists/awesome-bash) - Curated list of Bash resources and tools
- [Pure Bash Bible](https://github.com/dylanaraps/pure-bash-bible) - Collection of pure bash alternatives to external commands

---

*Originally from [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) (MIT), adapted under EUPL-1.2. Pinned at commit `d8e7e60f6fa962bd7842ae2a287361b0a6477f6a`.*

