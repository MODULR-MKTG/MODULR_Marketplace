# MODULR beehiiv Voice Mine

Reverse-engineer a brand-voice profile from the posts that are actually working on your list. Pulls your top performers via the beehiiv MCP, extracts patterns (opening moves, signature phrases, structure, rhythm), and either bootstraps `voice-os/context/brand-voice.md` or proposes a diff against the version you already have.

Designed to pair with the `modulr-voice-os` plugin — the file this skill writes is the same one `/draft-email` and `/score-email` already read.

## How to install

1. Open Cowork.
2. Install this plugin from the MODULR marketplace.
3. Make sure the beehiiv MCP is connected.

## Commands

| Command              | What it does                                                                                  |
| -------------------- | --------------------------------------------------------------------------------------------- |
| `/voice-mine-sends`  | Pull your top N posts and extract a voice profile from them. Bootstrap or diff brand-voice.md.|

## How it works

1. Pulls posts from the configured window (default last 90 days) and ranks by your chosen metric (default: a weighted blend of open rate and CTR).
2. Reads the body content of the top N (default 10).
3. Analyzes opening moves, sentence-length distribution, signature phrases, structure patterns, em-dash usage, paragraph-opener variety, CTA placement, and subject-line patterns.
4. Either writes a fresh `voice-os/context/brand-voice.md` (if missing or you confirm overwrite) or proposes a diff against the existing one.
5. Also saves the raw pattern report to `voice-os/outputs/voice-mine-{date}.md`.

## Why this matters

`modulr-voice-os` ships with a `/setup-voice-os` wizard that asks you to drag in 5–10 of your best past emails. If those emails already live in beehiiv, this skill replaces the drag-in step entirely — bigger sample, less effort, ranked by what actually performs on this list.

## Where output lives

- `voice-os/context/brand-voice.md` — the active voice profile other Voice OS skills consume.
- `voice-os/outputs/voice-mine-{YYYY-MM-DD}.md` — the per-run pattern report (paper trail).
- Nothing is written inside the plugin folder.

---

Built by MODULR. Questions: hello@gomodulr.com
