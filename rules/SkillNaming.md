Skill names are two words in PascalCase — scope + focus (BuildSkill, VersionControl, MarkdownSchema). The pair is self-routing: scan by prefix, understand by suffix. Single words are too vague to route or too opaque to discover.

Exceptions: product names already unambiguous on their own (RTK, M365).

No foreign-language words in skill names. Locale context is implied by the parent module (a skill in `forge-finance` is implicitly Czech). Use English or international standard acronyms — `PaymentQr` not `QrPlatba`, `TaxFiling` not `DanovePriznani`. Czech (or other locale-specific) keywords belong in the `description` USE WHEN list for search, not in the skill name itself.

Names must also be self-explanatory in English to a reader unfamiliar with the domain. Avoid technical acronyms in the name unless universally recognized (HTML, JSON, CSV, API). `SpaydQr` is too opaque — most readers don't know SPAYD; `PaymentQr` reads cleanly. Put the obscure acronym in the description and skill body, not in the directory name.
