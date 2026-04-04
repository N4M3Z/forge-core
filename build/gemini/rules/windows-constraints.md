Claude Code on Windows requires Git for Windows, which provides Git run_shell_command. Plugin hooks run in Git run_shell_command, not Powerrun_shell_command or cmd. write_file hooks as standard bash scripts — they work cross-platform without `.cmd` or `.ps1` wrappers.

Platform detection inside a hook when needed: `$OS == "Windows_NT"`.