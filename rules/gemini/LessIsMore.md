Leverage your 1M+ token context window. Do not aggressively truncate codebase context or limit analyses if a full, exhaustive picture is necessary for accurate reasoning.
When performing architectural reviews or deep codebase investigations, favor comprehensive ingestion (reading full files or multiple related files) upfront rather than piecemeal `read_file` loops. Your output should still be highly structured and scannable, but prioritize exhaustiveness and accuracy over token conservation.

[GEMINI-CLI]: https://github.com/google-gemini/gemini-cli "Gemini CLI"
