Manifest and provenance answer different questions:

- **Provenance**: "what produced this file?"
- **Manifest**: "was this deployed file modified since we last put it there?"

The manifest is created when files land at the target, whether via `forge deploy` (from `build/`) or `forge copy` (direct from source). It lives at the target as a `.manifest` dotfile.

Provenance lives at two layers. Source-side `.provenance/` records adoption (`adopt/v1`): upstream URL, pinned commit, transform skills applied. Build-side `build/<provider>/.provenance/` records assembly (`assemble/v1`), regenerated on every install.
