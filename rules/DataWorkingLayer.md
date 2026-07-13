Source documents live in `~/Documents`. Their extracted, machine-readable form is the working layer under `~/Data/<Type>/<project>/`, mirroring the source tree. The vault references that layer through a note's `paths:` pointer and never copies the working file's body into a note.

Three layers, one direction:

- `~/Documents`: original binaries (docx, pdf, xlsx), untouched.
- `~/Data/<Type>/<project>/`: extracted text plus per-project build material (scripts, fonts, images). Lossless, canonical, regenerable.
- vault: curated notes that point at the Data layer and carry the schema (frontmatter, summary, wikilinks).

Keep file stems identical across `~/Documents` and `~/Data` so a note's pointer and its source stay paired. Per-project build scripts and assets are working material: they live in the project's Data area, never in the vault and never in forge. Forge carries the method; each project's content is data.
