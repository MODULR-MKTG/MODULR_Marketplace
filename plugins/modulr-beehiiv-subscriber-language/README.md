# MODULR beehiiv Subscriber Language

Stop inventing what your readers care about. Mine the free-text from your beehiiv polls and surveys into a structured "audience language" file: fears they name, words they use, objections they raise, outcomes they describe — in their voice, with attribution.

Designed to pair with `modulr-voice-os`. The file this skill writes is read by `/draft-email` (for copy that speaks their language) and `/score-email` (for stricter audience-fit checking).

## How to install

1. Open Cowork.
2. Install this plugin from the MODULR marketplace.
3. Make sure the beehiiv MCP is connected.

## Commands

| Command                       | What it does                                                                              |
| ----------------------------- | ----------------------------------------------------------------------------------------- |
| `/mine-subscriber-language`   | Pull poll and survey free-text, theme it, and write `voice-os/context/audience-language.md`.|

## How it works

1. Pulls all polls and surveys in the chosen window (default last 12 months) via the beehiiv MCP.
2. Grabs free-text responses (multi-choice is skipped — it doesn't reveal vocabulary).
3. Themes the responses into five buckets: **fears, desires, objections, outcomes described, words they use vs. reject.**
4. Writes `voice-os/context/audience-language.md` with categories, exact quotes, and attribution (which poll/survey, anonymized respondent).
5. Surfaces a diff against your existing `voice-os/context/audience.md` so you can update sharper.

## Why this matters

The Voice OS engine already reads `voice-os/context/audience.md` before every draft. This skill makes that file evidence-based instead of self-described. The result: copy that uses your subscribers' actual words, not your guesses about their words.

## Where output lives

- `voice-os/context/audience-language.md` — the structured file other Voice OS skills consume.
- `voice-os/outputs/subscriber-language-{YYYY-MM-DD}.md` — the per-run mining report.
- Nothing is written inside the plugin folder.

---

Built by MODULR. Questions: hello@gomodulr.com
