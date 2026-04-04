Every repo should have a `.gitattributes` with `* text=auto eol=lf`. Files exported from Windows tools (SQL Server, Excel) arrive as UTF-16LE with CRLF — normalize to UTF-8 LF before committing.

When encountering binary diffs on text files (git shows `-  -` instead of line counts), check encoding with `file <path>`. Convert with `iconv -f UTF-16LE -t UTF-8` and strip CR with `tr -d '\r'`.
