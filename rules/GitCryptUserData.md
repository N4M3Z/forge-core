Modules with user-specific data (credentials, personal identifiers, insurance numbers) use git-crypt to encrypt those files in the public repo. Files are plaintext locally, encrypted blobs on push.

Setup:

```sh
brew install git-crypt
cd module-root
git-crypt init
git-crypt add-gpg-user YOUR_GPG_KEY_ID
```

Add a `.gitattributes` entry for the encrypted path:

```
rules/user/** filter=git-crypt diff=git-crypt
```

Remove `rules/user/` from `.gitignore` after git-crypt is configured — the files are now safe to commit.

The `rules/user/` directory holds per-user data that the module's skills need at runtime (insurance identifiers, API account slugs, tax office codes) but must not be readable in the public repo.

Until git-crypt is configured, `rules/user/` stays gitignored as a fallback.
