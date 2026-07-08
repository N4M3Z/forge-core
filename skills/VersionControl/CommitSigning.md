# Commit Signing

Two valid options for signing git commits with a hardware key. **GPG with the YubiKey OpenPGP slot + `pinentry-mac` is preferred** on macOS: pinentry handles the PIN dialog natively, `gpg-agent` talks to the YubiKey directly, no shim is needed. SSH with FIDO2 (`sk-ssh-ed25519`) is the alternative — equally accepted by GitHub/GitLab, but on macOS it needs a wrapper around Apple's `ssh-agent` (see below).

## GPG (preferred)

Configure git to sign with the YubiKey's OpenPGP signing subkey:

```sh
git config --global gpg.format openpgp
git config --global user.signingkey <KEY-ID>!         # trailing ! pins to the signing subkey
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

`pinentry-mac` (brew cask `pinentry-mac`) handles the PIN entry GUI; it's wired through `~/.gnupg/gpg-agent.conf`:

```
pinentry-program /opt/homebrew/bin/pinentry-mac
default-cache-ttl 3600
max-cache-ttl 86400
```

`gpg-agent` discovers the YubiKey OpenPGP slot on first signing operation and prompts for the PIN via pinentry-mac. Touch the YubiKey when the LED blinks.

## Batch re-signing: the `-c` config leak

You land in a re-signing rewrite when commits were authored under an email that does not match the signing key, so they never show Verified despite being signed. jj (and a freshly-initialized submodule's git) authors under whatever `user.email` its own config carries; if that is not the key's email, every commit is a future re-author. Prevent it: set `user.email` to the signing key's email in every colocated repo and every submodule level before the first commit. The rewrite below is the recovery for when you didn't.

When rewriting history and re-signing each commit (identity fix, email change), the natural pattern is to disable signing for the rebase replay and sign once per commit in the exec step:

```sh
git -c commit.gpgsign=false rebase --root --force-rebase \
    --exec 'git commit --amend --no-edit -S'
```

The `-S` is load-bearing. `git -c` exports the override through `GIT_CONFIG_PARAMETERS`, which every child process inherits, including the exec'd `git commit`. Without an explicit `-S`, the amend sees `commit.gpgsign=false` and silently produces unsigned commits: the rebase succeeds, no PIN or touch prompt ever appears, and `git log --format='%h %G?'` shows `N` on every commit. The absence of hardware prompts during a signing rebase is the tell.

The command-line `-S` outranks the inherited config, so the replay picks stay unsigned (no wasted hardware touches) and each amend signs exactly once. Verify after any batch rewrite:

```sh
git log --format='%h %G? %ae %s'    # expect G on every line
```

## SSH with FIDO2 (alternative)

Configure git to sign with an `sk-ssh-ed25519` (FIDO2/U2F) key:

```sh
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/<keyname>.pub
git config --global commit.gpgsign true
```

The matching private-key file (the credential handle) lives next to the `.pub`. Signing operations are routed through `ssh-keygen -Y sign`, which talks to libfido2 and then the YubiKey for touch + optional PIN.

### Apple's bundled `ssh-agent` refuses FIDO2

**Symptom** -- `git commit` fails immediately with:

```
Couldn't sign message (signer): agent refused operation?
Signing ... failed: agent refused operation?
fatal: failed to write commit object
```

even though:

- `ssh-add -L` shows the SK key loaded
- the YubiKey is plugged in and visible to YubiKey Manager
- the FIDO2 credential exists and the PIN is unlocked

**Root cause** -- macOS Sequoia and earlier ship an `ssh-agent` (launched by launchd, socket exported via `SSH_AUTH_SOCK`) that does not have FIDO2 support compiled in. Homebrew's `ssh-keygen` *does* support FIDO2. When git signs, `ssh-keygen` consults `SSH_AUTH_SOCK` first, hits Apple's agent, and gets "agent refused" because the agent cannot load the FIDO middleware. The same agent can serve regular `ssh` connections fine -- the failure only surfaces when an SK key is involved ([Yubico/libfido2 #464][LIBFIDO2], [Apple Developer Forums][APPLEDEV], [gitbutler #4140][GITBUTLER]).

### Quick verification

```sh
ssh-add -T ~/.ssh/<keyname>.pub                                   # agent path -- expect "agent refused operation"
env -u SSH_AUTH_SOCK ssh-keygen -Y sign -f ~/.ssh/<keyname>.pub \
    -n git <<< test                                               # direct path -- expect a valid signature
```

If the second succeeds and the first fails, you have this exact problem.

### Fix: wrapper that bypasses the agent

The wrapper is shipped with this skill at `./scripts/git-ssh-sign-macos`. Install it manually:

```sh
install -m 0755 ./scripts/git-ssh-sign-macos ~/.local/bin/git-ssh-sign-macos
git config --global gpg.ssh.program ~/.local/bin/git-ssh-sign-macos
```

Or run `scripts/configure/git-ssh-sign.sh` from forge-provision, which installs it idempotently as part of a fresh-Mac provisioning run.

Every git signing operation now goes direct to libfido2; SSH login, agent forwarding, and Keychain-cached passphrases for non-SK keys keep using Apple's agent. Reversible with `git config --global --unset gpg.ssh.program`.

The wrapper body is one line:

```sh
exec env -u SSH_AUTH_SOCK /opt/homebrew/bin/ssh-keygen "$@"
```

Strip `SSH_AUTH_SOCK` from the environment so `ssh-keygen` skips agent dispatch and talks to libfido2 + the YubiKey directly.

### `SSH_ASKPASS` is per-shell, not per-user

The PIN-entry GUI dialog (`theseal/ssh-askpass/ssh-askpass`) only fires when `SSH_ASKPASS` is exported in the signing process's environment. Most setups export it from `~/.zshenv` — which only loads for zsh-spawned processes. GUI-launched processes (an IDE, a Finder-launched terminal, a Spotlight-launched app) inherit launchd's environment and miss `SSH_ASKPASS`. Symptom: `git commit` hangs waiting on a TTY prompt, or returns "agent refused" without surfacing a dialog.

Two fixes:

1. **Launch from a terminal** (`open -a "AppName" .`) so the app inherits the zsh env.
2. **Export via launchd** so every process — GUI or shell — sees it:

```sh
launchctl setenv SSH_ASKPASS /opt/homebrew/bin/ssh-askpass
launchctl setenv SSH_ASKPASS_REQUIRE force
```

`launchctl setenv` survives until reboot; persist via a `LaunchAgent` plist for every boot.

### Verifying signatures

```sh
git log --show-signature -1                   # show sig on most recent commit
git verify-commit HEAD                         # exit 0 = good signature
git verify-tag <tag>
```

Local verification needs `~/.ssh/allowed_signers`:

```sh
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```

One entry per line, maps committer email to public key:

```
your.email@example.com sk-ssh-ed25519 AAAA...your.pubkey.contents... namespace="git"
```

`namespace="git"` keeps the signing scope to git only. GitHub uses its own `allowed_signers` server-side; this file only affects local `git verify-*` operations.

### Alternative fixes (without the wrapper)

| Approach | Trade-off |
|----------|-----------|
| Replace launchd `ssh-agent` with Homebrew's openssh | Survives OS updates only if you re-disable Apple's `org.openbsd.ssh-agent` each time; loses Keychain integration |
| Compile `sk-libfido2.dylib` from OpenSSH Portable + set `SSH_SK_PROVIDER` ([BertanT gist][BERTANT]) | Keeps Keychain integration; needs `ssh-agent -P` widened or full agent replacement |
| 1Password SSH agent | Vendor dependency; FIDO2 support is solid |

[LIBFIDO2]: https://github.com/Yubico/libfido2/issues/464
[APPLEDEV]: https://developer.apple.com/forums/thread/698683
[GITBUTLER]: https://github.com/gitbutlerapp/gitbutler/issues/4140
[BERTANT]: https://gist.github.com/BertanT/9d222da115ca2d1274ef34735c4260cf
