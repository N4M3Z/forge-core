Never write real names, email addresses, phone numbers, or credentials into tracked files. When writing examples, schemas, or sample output, replace identifiers with pseudonyms (Alice/Bob/Carol Example, +420600000001, alice@example.com) before writing.

This applies even when the data is "just an example" — tracked files are public, session context is not.

Exceptions: `plugin.json` author fields and LICENSE headers may use real attribution by design. Secrets belong in `.env` (gitignored), never in source.