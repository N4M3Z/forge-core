Negating a nullable type (`!$nullableString`) passes for both `null` and `''`. Use explicit comparisons: `=== null`, `!== null`, `=== ''`.

Static analyzers (Psalm, PHPStan, mypy, Clippy) enforce this distinction. Do not suppress their warnings -- fix the comparison.
