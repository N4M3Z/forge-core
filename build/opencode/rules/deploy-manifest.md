The manifest is created by the copy/deploy step and lives at the target (`.manifest` dotfile). Provenance sidecars are created by the assembly step and live in `build/`. Never conflate the two — they answer different questions:

- **Provenance**: "what sources produced this built file?" (build record)
- **Manifest**: "was this deployed file modified since we last put it there?" (deployment record)