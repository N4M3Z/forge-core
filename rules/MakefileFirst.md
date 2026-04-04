All module build, install, test, and lint logic runs through Makefiles. No standalone shell scripts that duplicate or bypass Make targets — they become invisible, untested, and unmaintainable.

Modules include shared fragments from forge-lib (`mk/*.mk`) and override only what differs. A new module should need ~20 lines of Makefile, not 200.
