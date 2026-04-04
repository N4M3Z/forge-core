## Derive Workflow

Infer a schema from existing documents and adjust it to match forge conventions.

### Step 1: Pick source files

Identify representative files to derive from. Prefer files that follow conventions well.

### Step 2: Run derive

```bash
mdschema derive "<file>"
```

This infers a schema from an existing document's structure.

### Step 3: Review and adjust

The derived schema may be too loose or too strict. Cross-reference with the [conventions table](SKILL.md#field-requirements-by-artifact-type) and adjust:
- Add missing required fields for the artifact type
- Set appropriate `max_depth` (3 for skills/agents, 4 for docs)
- Enable `no_skip_levels: true`

### Step 4: Write and validate

Write the adjusted schema and run validation against all target files:

```bash
mdschema check "<glob>" --schema <path>/.mdschema
```

Report results. If violations found, ask whether to fix the documents or adjust the schema.
