When a directory contains a `.mdschema` file, all markdown files in that directory must conform to it.

Before writing or editing a markdown file, check for a sibling `.mdschema`. If present, ensure:
- All required frontmatter fields are present
- Heading levels do not skip (h1 -> h3 without h2)
- Heading depth does not exceed `max_depth`