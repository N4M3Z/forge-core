Never include real credentials, API keys, tokens, passwords, PII, or internal URLs in agent output, commit messages, MR comments, or skill definitions. Use obviously fake placeholders (`example.com`, `<token>`, `user@example.com`) when demonstrating patterns.

When reviewing code that handles secrets, flag hardcoded values but do not echo them back. Reference by file path and line number only.
