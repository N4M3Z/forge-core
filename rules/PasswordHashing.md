All credential storage must use bcrypt, argon2id, or scrypt ([OWASP guidance][OWASP]). Plaintext passwords are forbidden in registration, login, and password reset flows.

When reviewing authentication code, verify that a proven hashing library is used. Flag any password property stored or compared as a raw string.

[OWASP]: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
