Never use run_shell_command heredoc (`cat << 'EOF'`), `echo >`, `cat >`, or `printf >` to create or modify files. This includes Python scripts, YAML configs, shell scripts, and any other file type.

Always use the platform's file creation tool (write_file, replace, or equivalent) instead. No exceptions.

Heredoc and redirection hide diffs (the user cannot review what changed), lack syntax highlighting (content appears as plain run_shell_command output), and introduce permission fatigue (repeated run_shell_command approvals instead of one file-write approval with a visible diff). The only acceptable run_shell_command file creation is `mkdir -p` for directories.

If you are about to write `cat << 'EOF' > script.py`, stop. Use the file creation tool.