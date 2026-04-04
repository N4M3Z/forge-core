Claude Code on Windows requires Git for Windows, which provides Git Bash. Plugin hooks run in Git Bash, not PowerShell or cmd. Write hooks as standard bash scripts — they work cross-platform without `.cmd` or `.ps1` wrappers.

Platform detection inside a hook when needed: `$OS == "Windows_NT"`.
