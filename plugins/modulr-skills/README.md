# modulr-skills

A growing collection of standalone skills MODULR uses in production. Steal anything useful.

Everything in this bundle is **MODULR's own work** (or, where it builds on a public idea, the original thinker is credited inline). We don't republish other people's skills here — if a skill we love is someone else's, we point you to their source instead of re-hosting it.

## Skills in this bundle

| Skill | What it does |
|---|---|
| `anti-ai-phrases` | Scrubs copy of the words and structural patterns that signal AI-generated writing. |
| `price-check` | An objective pricing audit for proposals/SOWs/retainers — replaces vibes-based underpricing with market-anchored math. Thesis credit: Matthew Antieau ("msantiwork"). |
| `email-engagement-analysis` | Deep-dive analysis of a client's email program (opens/clicks/CTOR, list growth, subject performance) into a branded PDF that reframes how leadership reads email. |
| `email-deliverability` | Diagnose and fix why email goes to spam — live SPF/DKIM/DMARC audit, Postmaster spam-rate read, warm-up/deferral playbook, and Gmail/Yahoo/Microsoft bulk-sender compliance. |
| `musk-algorithm` | A first-principles efficiency audit (requirements → delete → simplify → accelerate → automate) for code, ops, or product scope. Framework credit: Elon Musk's stated "5-step algorithm." |

More on the way.

## Publishing safely (maintainers)

These skills are hand-scrubbed copies of the internal versions we run day to day. The internal copies contain client names, paths, and infra that must never ship. To keep leaks out and catch drift, run the gate before every publish:

```bash
scripts/leak-gate.sh            # fails if any internal marker leaked; warns on drift
scripts/leak-gate.sh --strict   # also fails on drift (use in CI)
scripts/leak-gate.sh --record   # after a verified hand-scrub, stamp new drift baselines
```

- **Leak gate** scans every published skill and hard-fails on personal paths, client/prospect names, infra IDs, or vault paths. The pattern list in the script is the single source of truth for "what counts as a leak" — add new clients/repos/infra there as they appear.
- **Drift check** compares each published skill to its internal source (`~/.claude/skills/`). Because the published copies are rewritten by hand (not mechanically derived), a changed source means *re-scrub by hand*, then `--record` to update the baseline. The `.source-hash` files store those baselines and are committed.

Rule: never publish a skill that fails the gate, and never `--record` until you've confirmed the scrub by eye.

## License

MIT — steal anything useful. Where a skill builds on someone else's public idea, that creator is credited within the skill; the credit travels with the work.
