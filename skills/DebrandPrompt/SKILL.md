---
name: DebrandPrompt
description: "Remove hardcoded vendor names, brand references, and external-service dependencies from a prompt-shaped document. USE WHEN an adopted skill hardcodes specific tool names, company brands, or paid service dependencies that would bias the skill toward one ecosystem."
version: 0.1.0
allowed-tools: Read, Edit, Grep
---

# DebrandPrompt

Strip vendor and brand references from a prompt-shaped document so the skill generalizes across ecosystems. Referenced by [ForgeAdopt](../ForgeAdopt/SKILL.md) as the `debrand` transform.

## What to remove

| Pattern                                      | Example                                                  | Replace with                                |
| -------------------------------------------- | -------------------------------------------------------- | ------------------------------------------- |
| Hardcoded vendor tool name in core guidance  | "Use Docker Scout for vulnerability scanning"            | "Use a vulnerability scanner"               |
| "Powered by X" or partner-credit language    | "Built on top of Supabase"                               | Remove                                      |
| External-service dependency as mandatory     | "Configure Kong as the API gateway"                      | "Configure an API gateway"                  |
| Specific author attribution in body          | "The codex team recommends..."                           | Remove attribution, keep the recommendation |
| Marketing affiliate language                 | "With built-in Auth0 integration"                        | "With authentication integration"           |
| First-person voice tied to a specific org    | "Our team uses X"                                        | Describe the pattern, not the org           |

## What to preserve

- Vendor names that appear in **anti-pattern citations**: "avoid Inter, Roboto, Arial" stays — the names are the signal
- Vendor names that identify a standard (HTTP, OAuth, SAML, TLS) — these are protocol names, not brands
- Commands and package names in code blocks when they are the actual invocation the user needs
- License attributions in frontmatter or companion files

## The anti-pattern test

Ask: if I replaced this vendor name with `<category>`, does the sentence still convey the instruction?

- "Use Docker Scout" → "Use a vulnerability scanner" — passes, debrand it
- "Avoid Inter and Roboto" → "Avoid <font>s and <font>s" — fails, keep the names because they ARE the content

## Procedure

1. Grep for common vendor markers: capitalized product names, `@` handles, URLs pointing to non-standard services.
2. For each match, apply the anti-pattern test.
3. When removing, replace with the category (scanner, gateway, font, service) — do not delete in place.
4. Update `allowed-tools` if a removed vendor tool implied a tool grant.
5. Re-read; the skill should read as ecosystem-neutral where appropriate.

## Constraints

- Never remove vendor names from anti-pattern lists — they are the directive
- Do not neutralize protocol names (HTTP, TLS, OAuth) — these are universal
- If the skill is explicitly about a specific vendor (for example, a Fakturoid skill), do not debrand — the vendor is the scope
- When in doubt between debranding and preserving, preserve and flag for review
