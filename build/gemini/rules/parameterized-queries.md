All SQL must use parameterized queries ([OWASP guidance][1]). No string interpolation or concatenation in query construction.

Flag: string interpolation in SQL context, format strings with table/column names from user input, dynamic ORDER BY without allowlist. Accept: parameter placeholders with bound values via the database driver's parameter API.