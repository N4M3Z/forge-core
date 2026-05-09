---
title: Forge Introduction (EN)
tags:
  - forge
  - resource/document
keywords:
related:
---

So I am first going to share this here. As I mentioned, my main focus these days outside Proton is on building an open LLM orchestration infrastructure. The core concept is to keep all AI context (identity, preferences, goals, behavioral rules) as plain markdown files, and the system crunches them into whatever format it currently needs using leveraging tools available on the machine. Key principles:

Tool-agnostic — the same source files generate CLAUDE.md (Claude Code), GEMINI.md (Gemini), AGENTS.md (Codex/OpenCode), etc. You write the repo once, use it everywhere. Markdown is plain-text instructions, so just like Obsidian notes, it's future-proof.
Modular architecture — every piece is a standalone git repo, usable individually. You don't need the full stack. Each module leverages different CLI tools and offers specialized agents for async tasks.
Self-improving skill system — markdown files that define what capabilities the AI has and how it performs them. Models learn during sessions on their own and propose how to further improve implemented and used skills.

Built on Rust + shell + markdown, runs on macOS, should work on Linux. I'm not going to bother with Windows right now (use the Unix subsystem). I call it FORGE. Individual modules explained in the thread — you can download and test them independently.

All modules are configured via config.yaml / defaults.yaml.

Warning!! Massively WIP, expect sweeping changes.
Right now I have one scaffold writing code (e.g. Claude Code) while the other one objects and does reviews (e.g. Gemini CLI).

Pull requests and testing welcome.

---
<https://github.com/N4M3Z/forge-tlp> — access control for AI tools.

**Problem:** AI coding tools see everything in the workspace. Contacts, journals, credentials, finances. You don't want that.
**Solution:** Traffic Light Protocol classification. You create a .tlp file with glob patterns under RED / AMBER / GREEN / CLEAR headers.

- RED = AI never sees it.
- AMBER = reading is blocked, but edits are allowed + `safe-read` strips `#tlp/red` sections and redacts secrets.
- GREEN / CLEAR = open.
- Automatic secret detection (API keys, tokens) via gitleaks patterns.

The module implements binaries that guarantee safe read/write. Rust, builds on first use. Works as a standalone plugin. I'll add PGP eventually, but that'll likely be a separate module.

---
<https://github.com/N4M3Z/forge-reflect>
Self-learning and memory management. AI sessions generate A TON of implicit knowledge. Without enforcement, nothing gets captured. This turns it into a habit. (The module reads session transcripts.)

Specifically it does two things:

SessionStart: Runs a `surface` digest at the start of every session — shows overdue backlog items, pending reminders, stale ideas, journal gaps, captured browser tabs. Essentially a briefing of everything that got buried in the noise.
Stop hook: When a larger session ends (10+ tool turns, 4+ user messages), it checks whether any insights or imperatives were captured. If not, it blocks exit and forces the user to reflect — otherwise it figures it out and saves it on its own. Forces itself to actually learn from sessions.

Also a PreCompact hook — adds reflection context before the AI compresses memory. Outputs are written to Ideas/ / Insights/ / Imperatives/, which it then loads into context when you're doing something else.

---
<https://github.com/N4M3Z/forge-apple>

Tools for the Apple ecosystem. Calendar + Reminders via ekctl (EventKit CLI). AI sees your calendar, creates events, manages tasks, plans your day. Instead of manually copying data from the calendar, the AI simply sees what you have scheduled and handles travel time, deadlines, conflicts. I use this daily for daily planning.

On top of that some additional skills:

- Apple Music playlist automation — you give AI a JSON spec, it builds playlists in Music.app via AppleScript.
- Safari tab capture (local + iCloud tabs from other devices) — less interesting, but occasionally useful for context.

macOS only, obviously. ekctl is a separate dependency — without it Calendar/Reminders won't work. It can also open Apple Maps and plan a route, etc.

---
<https://github.com/N4M3Z/forge-obsidian>

Teaches AI to work with an Obsidian vault. A lot of people use [Obsidian](https://obsidian.md/) as a knowledge base, but AI tools don't natively understand wikilinks, frontmatter schemas, or tag structure. Skills include:

Draft/Promote workflow: Pulls a skill into the vault, you edit it in Obsidian as a normal note, then promote it back to the module and push via git. (Extra metadata is parked in a sidecar.)

Useful if you have any structured knowledge base in Obsidian and want AI to work with it correctly instead of treating it as generic markdown.

---
<https://github.com/N4M3Z/forge-avatar>

You write an Identity.md (who you are), Preferences.md (communication style, code conventions), Goals.md (what you're working on). Optionally deeper self-knowledge — Beliefs, Strategies, Mental Models, Challenges, Frames, etc. At session start, the AI loads your avatar and operates aligned with your preferences and goals.

Basically a system for transferring identity across tools. Planned skills include running an interview with you via any voice interface (e.g. ChatGPT) and generating these documents from the recording. It'll be able to read chat history from Discord, etc. There are also some agents like ghostwriter, etc.

---
<https://github.com/N4M3Z/forge-journals>

**Proactive effort tracking by AI.** If AI is already helping with work, it can simultaneously log what was done. Effort logging as a byproduct of work, not as a standalone chore. Skills:

- /Log (quick one-liner entry)
- /DailyPlan (generates a daily plan from calendar + backlog)
- /DailyReview (evening review)
- /WeeklyReview (weekly summary)
- /Timesheet (timesheet from effort entries) for invoices
- /BacklogJournals (backlog management)

Effort tags: #log/effort/short (~30min), #log/effort/mid (~1h), long (~90min), /extended (2h+). AI logs during sessions automatically — you don't ask, it records it anyway. PreToolUse hook enforces the format.

---
And finally the scaffold: <https://github.com/N4M3Z/forge-core> — the workbench that everything plugs into:

- Build system (`make install`, `make test`, etc.)
- forge-init.sh generates a scaffold for your platform (Claude Code, OpenCode, etc.)
- forge-update.sh regenerates configurations when content changes
- The scaffold handles module dispatch in a defined order and wiring of skills and hooks into the given ecosystem (WIP!)

The foundation of everything is git and markdown, that's it.

---

Watch the GitHub and really feel free contribute and send PRs, skills and modules are being added basically every day. I just spewed out <https://github.com/N4M3Z/forge-images> because I needed to upscale an image and convert it to SVG.

Of course it's possible that some code won't work out of the box, won't run directly in something other than Claude Code, or that I missed something fundamental or even PIIs. If you find anything, obviously let me know and let's collab on this!

---
I'm also adding a WIP module for lazy loading to optimize token usage for those not using Claude Code: <https://github.com/N4M3Z/forge-load>
