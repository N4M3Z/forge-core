#!/usr/bin/env python3
"""Validate ADR frontmatter against a JSON schema.

Fallback for environments without check-jsonschema or ajv-cli.
Prefer the upstream tools when available:

    check-jsonschema --schemafile templates/forge-adr.json docs/decisions/*.md
    npx ajv validate -s templates/forge-adr.json -d docs/decisions/*.md

Usage:
    validate-adr.py <schema> <file|directory>
    validate-adr.py templates/forge-adr.json docs/decisions/
"""

import json
import re
import sys
from pathlib import Path


def extract_frontmatter_fields(path):
    content = path.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return None

    fields = {}
    for line in match.group(1).splitlines():
        key_match = re.match(r"^([a-z][a-z0-9_-]*)\s*:", line)
        if key_match:
            key = key_match.group(1)
            value = line[key_match.end():].strip()
            fields[key] = value
    return fields


def validate(fields, schema):
    problems = []

    missing = [key for key in schema.get("required", []) if key not in fields]
    if missing:
        problems.append(f"missing: {missing}")

    for key, prop in schema.get("properties", {}).items():
        if key not in fields:
            continue
        if "enum" in prop:
            value = fields[key].strip('"').strip("'")
            if value not in prop["enum"]:
                problems.append(f"{key}: '{value}' not in {prop['enum']}")

    return problems


def main():
    if len(sys.argv) < 3:
        print(__doc__.strip())
        sys.exit(2)

    schema_path = Path(sys.argv[1])
    target = Path(sys.argv[2])
    schema = json.loads(schema_path.read_text(encoding="utf-8"))

    files = sorted(target.glob("*.md")) if target.is_dir() else [target]

    passed = 0
    failed = 0

    for filepath in files:
        if not filepath.is_file():
            continue

        fields = extract_frontmatter_fields(filepath)
        if fields is None:
            print(f"  SKIP  {filepath}  (no frontmatter)")
            continue

        problems = validate(fields, schema)
        if problems:
            print(f"  FAIL  {filepath}  ({'; '.join(problems)})")
            failed += 1
        else:
            print(f"  PASS  {filepath}")
            passed += 1

    print(f"\n{passed} passed, {failed} failed")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
