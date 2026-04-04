All credential storage must use bcrypt, argon2id, or scrypt ([OWASP guidance][1]). Plaintext passwords are forbidden in registration, login, and password reset flows.

When reviewing authentication code, verify that a proven hashing library is used. Flag any password property stored or compared as a raw string.

[1]: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
