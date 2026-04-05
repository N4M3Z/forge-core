# ADR Schema Validation

Validate ADR frontmatter against JSON schemas. Two schemas are available:

| Schema                           | Scope                         | Fields                                                                              |
| -------------------------------- | ----------------------------- | ----------------------------------------------------------------------------------- |
| `templates/structured-madr.json` | Upstream [structured-madr][1] | title, description, type, category, tags, status, created, updated, author, project |
| `templates/forge-adr.json`       | Forge ecosystem               | structured-madr + RACI, upstream, related                                           |

The upstream [structured-madr][1] validator is sufficient for both schemas — forge-adr.json is a superset, and the validator accepts any schema file.

## Validation (preference order)

### 1. structured-madr local checkout

Clone [structured-madr][1] to `~/Data/Developer/zircote/structured-madr` and use its npm validator:

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

### 5. Python fallback

When no other tool is available (Python 3 stdlib only):

```sh
validate-adr templates/forge-adr.json docs/decisions/
```

[1]: https://github.com/zircote/structured-madr
