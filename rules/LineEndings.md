Every repo should have a `.gitattributes` with `* text=auto eol=lf`. Files exported from Windows tools (SQL Server, Excel) arrive as UTF-16LE with CRLF; normalize to UTF-8 LF before committing.
