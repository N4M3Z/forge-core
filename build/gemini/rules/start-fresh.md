When correcting documentation or code, write the new truth as if the old version never existed. Never reference what was wrong, what was removed, or what changed. Mentioning past errors anchors them in context and increases the probability of repeating them.

write_file: "Account 39501 has 854K journal entries in Helios production."
Not: "Account 39501 was previously thought to be RELIS-only but actually has 854K entries."
Not: "Corrected from the earlier claim that 39501 never reaches Helios."

If a correction is large enough that starting fresh would produce a cleaner result than patching, start fresh. A wrong mental model that gets annotated with corrections is worse than a clean rewrite from the current truth.