#!/usr/bin/env python3
"""Validate ADR frontmatter against a JSON schema.

Fallback for environments without check-jsonschema or ajv-cli.
Prefer the upstream tools when available:

    check-jsonschema --schemafile templates/forge-adr.json docs/decisions/*.md
    npx ajv validate -s templates/forge-adr.json -d docs/decisions/*.md

Usage:
    validate-adr.py <schema> <file|directory>
    validate-adr.py templates/forge-adr.json docs/decisions/
    validate-adr.py --test
"""

import json
import re
import sys
from datetime import date
from pathlib import Path

try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False

DATE_PATTERN = re.compile(r"^\d{4}-\d{2}-\d{2}$")
TAG_PATTERN = re.compile(r"^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$")


def extract_frontmatter(path):
    content = path.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return None

    raw_frontmatter = match.group(1)

    if HAS_YAML:
        data = yaml.safe_load(raw_frontmatter)
        if not isinstance(data, dict):
            return None
        for key, value in data.items():
            if isinstance(value, (date,)):
                data[key] = value.isoformat()
        return data

    fields = {}
    current_key = None
    current_list = None

    for line in raw_frontmatter.splitlines():
        key_match = re.match(r"^([a-z][a-z0-9_-]*)\s*:(.*)", line)
        if key_match:
            if current_key and current_list is not None:
                fields[current_key] = current_list

            current_key = key_match.group(1)
            value = key_match.group(2).strip()

            if value.startswith("[") and value.endswith("]"):
                inner = value[1:-1].strip()
                if inner:
                    fields[current_key] = [
                        item.strip().strip('"').strip("'")
                        for item in inner.split(",")
                    ]
                else:
                    fields[current_key] = []
                current_key = None
                current_list = None
            elif value == "":
                current_list = []
            else:
                fields[current_key] = value.strip('"').strip("'")
                current_key = None
                current_list = None
        elif current_list is not None and line.strip().startswith("- "):
            item = line.strip()[2:].strip().strip('"').strip("'")
            current_list.append(item)

    if current_key and current_list is not None:
        fields[current_key] = current_list

    return fields


def validate(data, schema):
    problems = []

    missing = [key for key in schema.get("required", []) if key not in data]
    if missing:
        problems.append(f"missing: {missing}")

    for key, prop in schema.get("properties", {}).items():
        if key not in data:
            continue
        value = data[key]

        expected_type = prop.get("type")
        if expected_type == "string" and not isinstance(value, str):
            problems.append(f"{key}: expected string, got {type(value).__name__}")
        elif expected_type == "array" and not isinstance(value, list):
            problems.append(f"{key}: expected array, got {type(value).__name__}")

        if "const" in prop and value != prop["const"]:
            problems.append(f"{key}: expected '{prop['const']}', got '{value}'")

        if "enum" in prop:
            check_value = value.strip('"').strip("'") if isinstance(value, str) else value
            if check_value not in prop["enum"]:
                problems.append(f"{key}: '{check_value}' not in {prop['enum']}")

        if prop.get("format") == "date" and isinstance(value, str):
            if not DATE_PATTERN.match(value):
                problems.append(f"{key}: '{value}' is not YYYY-MM-DD")

        if "pattern" in prop and isinstance(value, str):
            if not re.match(prop["pattern"], value):
                problems.append(f"{key}: '{value}' does not match pattern")

        if "minLength" in prop and isinstance(value, str):
            if len(value) < prop["minLength"]:
                problems.append(f"{key}: length {len(value)} < minLength {prop['minLength']}")

        if expected_type == "array" and isinstance(value, list):
            if "minItems" in prop and len(value) < prop["minItems"]:
                problems.append(f"{key}: {len(value)} items < minItems {prop['minItems']}")

            item_schema = prop.get("items", {})
            item_pattern = item_schema.get("pattern")
            item_min_length = item_schema.get("minLength")
            for item in value:
                if isinstance(item, str):
                    if item_pattern and not re.match(item_pattern, item):
                        problems.append(f"{key}: item '{item}' does not match pattern")
                    if item_min_length is not None and len(item) < item_min_length:
                        problems.append(f"{key}: item '{item}' length < minLength {item_min_length}")

    return problems


def run_tests():
    schema = {
        "required": ["title", "type", "status", "created", "tags"],
        "properties": {
            "title": {"type": "string", "minLength": 1},
            "type": {"type": "string", "const": "adr"},
            "status": {"type": "string", "enum": ["proposed", "accepted", "deprecated", "superseded"]},
            "created": {"type": "string", "format": "date"},
            "tags": {
                "type": "array",
                "minItems": 1,
                "items": {"type": "string", "minLength": 1, "pattern": "^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$"}
            },
        },
    }

    tests_passed = 0
    tests_failed = 0

    def assert_test(name, data, expected_pass):
        nonlocal tests_passed, tests_failed
        problems = validate(data, schema)
        actual_pass = len(problems) == 0
        if actual_pass == expected_pass:
            print(f"  PASS  {name}")
            tests_passed += 1
        else:
            status = "should have passed" if expected_pass else "should have failed"
            print(f"  FAIL  {name} ({status}, problems: {problems})")
            tests_failed += 1

    assert_test("valid ADR", {
        "title": "Test Decision",
        "type": "adr",
        "status": "accepted",
        "created": "2026-03-30",
        "tags": ["architecture"],
    }, True)

    assert_test("missing required field", {
        "type": "adr",
        "status": "accepted",
        "created": "2026-03-30",
        "tags": ["architecture"],
    }, False)

    assert_test("invalid enum", {
        "title": "Test",
        "type": "adr",
        "status": "fantasy",
        "created": "2026-03-30",
        "tags": ["architecture"],
    }, False)

    assert_test("invalid const", {
        "title": "Test",
        "type": "not-adr",
        "status": "accepted",
        "created": "2026-03-30",
        "tags": ["architecture"],
    }, False)

    assert_test("invalid date format", {
        "title": "Test",
        "type": "adr",
        "status": "accepted",
        "created": "March 30 2026",
        "tags": ["architecture"],
    }, False)

    assert_test("invalid tag pattern", {
        "title": "Test",
        "type": "adr",
        "status": "accepted",
        "created": "2026-03-30",
        "tags": ["UPPER_CASE"],
    }, False)

    assert_test("tags as string instead of array", {
        "title": "Test",
        "type": "adr",
        "status": "accepted",
        "created": "2026-03-30",
        "tags": "not-an-array",
    }, False)

    assert_test("empty tags array", {
        "title": "Test",
        "type": "adr",
        "status": "accepted",
        "created": "2026-03-30",
        "tags": [],
    }, False)

    assert_test("empty title string", {
        "title": "",
        "type": "adr",
        "status": "accepted",
        "created": "2026-03-30",
        "tags": ["architecture"],
    }, False)

    assert_test("empty string in tags array", {
        "title": "Test",
        "type": "adr",
        "status": "accepted",
        "created": "2026-03-30",
        "tags": [""],
    }, False)

    print(f"\n{tests_passed} passed, {tests_failed} failed")
    return tests_failed == 0


def run_fixture_tests(schema_path, fixture_root):
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    passed = 0
    failed = 0

    for expected_result, directory in [("valid", fixture_root / "valid"), ("invalid", fixture_root / "invalid")]:
        if not directory.is_dir():
            continue
        for filepath in sorted(directory.glob("*.md")):
            data = extract_frontmatter(filepath)
            if data is None:
                if expected_result == "invalid":
                    print(f"  PASS  {filepath.name}  (no frontmatter = invalid)")
                    passed += 1
                else:
                    print(f"  FAIL  {filepath.name}  (no frontmatter, expected valid)")
                    failed += 1
                continue

            problems = validate(data, schema)
            actually_valid = len(problems) == 0

            if (expected_result == "valid") == actually_valid:
                print(f"  PASS  {filepath.name}")
                passed += 1
            else:
                expected = "pass" if expected_result == "valid" else "fail"
                print(f"  FAIL  {filepath.name}  (expected {expected}, problems: {problems})")
                failed += 1

    print(f"\n{passed} passed, {failed} failed")
    return failed == 0


def main():
    if len(sys.argv) >= 2 and sys.argv[1] == "--test":
        script_directory = Path(__file__).resolve().parent
        module_root = script_directory.parent.parent
        fixture_root = module_root / "tests" / "fixtures"

        print("Unit tests:")
        unit_success = run_tests()

        fixture_success = True
        if fixture_root.is_dir():
            schema_path = module_root / "templates" / "forge-adr.json"
            if schema_path.is_file():
                print("\nFixture tests:")
                fixture_success = run_fixture_tests(schema_path, fixture_root)

        sys.exit(0 if (unit_success and fixture_success) else 1)

    if len(sys.argv) < 3:
        print(__doc__.strip())
        sys.exit(2)

    schema_path = Path(sys.argv[1])
    target = Path(sys.argv[2])
    schema = json.loads(schema_path.read_text(encoding="utf-8"))

    files = sorted(target.glob("*.md")) if target.is_dir() else [target]

    if not HAS_YAML:
        print("  NOTE  pyyaml not installed, using regex fallback (type/format checks limited)")

    passed = 0
    failed = 0

    for filepath in files:
        if not filepath.is_file():
            continue

        data = extract_frontmatter(filepath)
        if data is None:
            print(f"  SKIP  {filepath}  (no frontmatter)")
            continue

        problems = validate(data, schema)
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
