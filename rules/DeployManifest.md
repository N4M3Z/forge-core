The manifest is created when files land at the target — whether via `forge deploy` (from `build/`) or `forge copy` (direct from source). It lives at the target as a `.manifest` dotfile. Provenance sidecars are created by the assembly step and live in `build/`. Never conflate the two — they answer different questions:

- **Provenance**: "what sources produced this built file?" (build record, assembly step)
- **Manifest**: "was this deployed file modified since we last put it there?" (deployment record, deploy or copy step)
