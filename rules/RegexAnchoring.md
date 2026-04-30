Regex patterns that extract security-sensitive values (email addresses, tokens, header fields) must use positional anchors (`$`, `\z`, `^`).

Without anchoring, an input like `"<a@good.com>" <a@evil.com>` matches the attacker-controlled address. Anchor to the end of the string or the specific boundary the format requires.
