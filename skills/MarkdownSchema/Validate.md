## Validate Workflow

Check markdown files against their `.mdschema` and report violations.

### Step 1: Find the schema

Look for `.mdschema` in the target directory. If not found:
- Check parent directory
- Offer to create one using the [Create Workflow](SKILL.md#create-workflow)

### Step 2: Run validation

```bash
mdschema check "<glob>" --schema <path>/.mdschema
```

### Step 3: Report

For each violation, explain:
- **What failed** -- missing field, heading skip, depth exceeded
- **Why it matters** -- e.g., missing `version` means mdschema can't catch `metadata.version` nesting errors
- **How to fix** -- add the field, restructure headings, or adjust the schema if the constraint is wrong

If no violations: report clean pass with file count.
