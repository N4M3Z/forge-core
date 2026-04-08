# ADR Schema Validation

Validate ADR frontmatter against JSON schemas. Two schemas are available:

| Schema                           | Scope                         | Fields                                                                              |
| -------------------------------- | ----------------------------- | ----------------------------------------------------------------------------------- |
| `templates/structured-madr.json` | Upstream [structured-madr][MADR] | title, description, type, category, tags, status, created, updated, author, project |
| `templates/forge-adr.json`       | Forge ecosystem               | structured-madr + RACI, upstream, related                                           |

Use the fork of [structured-madr validator][FORK] — the upstream validator enforces body structure that doesn't match the forge-adr template (N4M3Z/forge-core#8).

[FORK]: https://github.com/N4M3Z/structured-madr

## Validation (preference order)

### 1. structured-madr local checkout

Clone [structured-madr][MADR] to `~/Data/Developer/zircote/structured-madr` and use its npm validator:

```sh
git clone https://github.com/zircote/structured-madr.git ~/Data/Developer/zircote/structured-madr
cd ~/Data/Developer/zircote/structured-madr && npm ci
```

Validate:

```sh
INPUT_PATH=docs/decisions INPUT_SCHEMA=templates/forge-adr.json npm run validate --prefix ~/Data/Developer/zircote/structured-madr
```

### 2. check-jsonschema

```sh
pip install check-jsonschema
check-jsonschema --schemafile templates/forge-adr.json docs/decisions/*.md
```

### 3. ajv-cli

```sh
npx ajv validate -s templates/forge-adr.json -d docs/decisions/*.md
```

### 4. GitHub Action (CI)

```yaml
- uses: zircote/structured-madr@main
  with:
      path: docs/decisions
      schema: templates/forge-adr.json
      fail-on-error: true
```

[MADR]: https://github.com/zircote/structured-madr
