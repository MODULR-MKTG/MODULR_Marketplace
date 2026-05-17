---
name: voice-mine-sends
description: Pull the user's top-performing beehiiv posts and reverse-engineer a brand-voice profile from them. Bootstrap a new voice-os/context/brand-voice.md or propose a diff against the existing one. Triggers on "/voice-mine-sends," "mine my voice from sends," "extract voice from my emails," "build voice profile from beehiiv," "what does my voice sound like," or any request to derive a voice profile from past beehiiv content.
---

# /voice-mine-sends

Mine the user's top-performing beehiiv posts for voice patterns. Output is either a fresh `voice-os/context/brand-voice.md` or a proposed diff against the existing one — never a generic voice description.

## Before you start

1. **The beehiiv MCP must be connected.** If not, stop and tell the user.
2. Confirm the publication. If more than one, ask which.

## Configure the mine

Ask via AskUserQuestion only if not specified:

1. **Window** — last 30 / 60 / 90 / 180 days (default 90)
2. **Sample size** — top 5 / top 10 / top 20 (default 10)
3. **Ranking metric** — open rate / CTR / blended (default blended: 0.5 × open-rate-percentile + 0.5 × CTR-percentile)
4. **Mode** — bootstrap (write a fresh file) / diff (propose changes against existing `voice-os/context/brand-voice.md`)
   - If `voice-os/context/brand-voice.md` does not exist, default to bootstrap.
   - If it exists, default to diff and confirm with user before overwriting.

## Pull the data

1. `mcp__beehiiv__list_posts` — all confirmed sends in the chosen window. Page through all results.
2. For each: `mcp__beehiiv__get_post_stats` to get open rate and CTR.
3. Rank by the chosen metric, pick the top N.
4. For each of the top N: `mcp__beehiiv__get_post_content` to pull body content + subject + preview.

## Analyze (per post, then aggregate)

For each post, extract:

1. **Opening move** — first sentence pattern (question / observation / hook / direct address / scene-set / contrarian claim / number-led)
2. **Sentence-length distribution** — mean, median, max, % under 8 words (fragments)
3. **Contractions usage** — count per 100 words
4. **Em-dash count** — body only, excluding lists
5. **Paragraph-opener variation** — list the first 1-2 words of each paragraph; flag if any repeat consecutively
6. **CTA placement** — single CTA / multiple CTAs / inline CTA / end-only / P.S. CTA
7. **Body length** — word count
8. **Signature phrases** — any 2-5 word phrase that appears verbatim across at least 3 of the top N posts
9. **Subject-line patterns** — length, specificity markers (numbers, names, dollar amounts), question vs. statement, ALL-CAPS / Title Case / sentence case
10. **Voice-IS-NOT signals** — things consistently absent (e.g. zero em-dashes, no rhetorical questions, no "imagine this")

Aggregate across the top N:

- Three most common opening moves (with counts)
- Top 5 signature phrases (with counts and sample contexts)
- Modal sentence-length pattern
- Modal CTA placement
- Modal subject-line pattern
- Three things the voice consistently AVOIDS

## Write the report

Always write `voice-os/outputs/voice-mine-{YYYY-MM-DD}.md` first:

```
# Voice mine — {publication} — {date}

## Sample

Top {N} posts by {metric} in last {N} days. Ranked:

1. "{title}" — {open}% open / {ctr}% CTR — sent {date}
2. ...

## Aggregated patterns

### Opening moves (top 3)
1. {pattern} — appeared in {N}/{total} posts
2. ...

### Signature phrases
- "{phrase}" — appeared {N} times across {M} posts
- ...

### Sentence rhythm
- Median sentence length: {N} words
- Fragments (<8 words): {X.X}% of sentences
- Em-dashes per post (body): {N}

### Paragraph rhythm
- Modal opener variation: {description}
- Consecutive same-word opener cases: {N}

### CTA pattern
- Modal placement: {pattern}

### Subject lines
- Median length: {N} chars / {N} words
- Specificity rate: {X.X}% include a number / name / dollar amount
- Modal case: {sentence / title / all-caps}

### Voice IS NOT
- {pattern consistently absent}
- ...

## Sample lines (the voice in action)

> {actual quote from top post 1}

> {actual quote from top post 2}

> {actual quote from top post 3}
```

## Then bootstrap OR diff

### If bootstrap mode

Write `voice-os/context/brand-voice.md` using the same structure the `setup-voice-os` wizard uses (see `references/context-templates/brand-voice.md` in `modulr-voice-os` if installed, otherwise use the structure: who-is-the-voice / three-pillars / voice-is / voice-is-not / sentence-structure / vocabulary-patterns / signature-phrases / opening-moves / closing-moves / tone-variations / gut-check-questions).

Fill every section from the aggregated patterns, with **direct quotes from the user's actual posts as evidence** for each claim. Never invent a pattern that isn't in the evidence.

If the voice-os/ folder doesn't exist yet, create the standard layout (`voice-os/context/`, `voice-os/outputs/`).

Then tell the user: **"Read voice-os/context/brand-voice.md out loud. If it sounds like a description of someone else, tell me which section feels off. If it sounds like you, you're ready to run /draft-email."**

### If diff mode

Read the existing `voice-os/context/brand-voice.md`. For each section, compare what's there to what the mine found. Surface ONLY the deltas — don't repeat agreement.

Format the diff in chat:

```
Diff against voice-os/context/brand-voice.md:

### Signature phrases
+ Add: "the thing nobody tells you" — appeared 4 times across top 10
+ Add: "here's the kicker" — appeared 3 times
- Remove: "let me be honest" — not present in any top-10 post in the last 90 days

### Opening moves
+ Add: "Direct question to one person" — now the modal pattern (5/10), wasn't listed
+ Reorder: "Scene-set" is currently listed first but now appears in only 2/10 — move down

### Sentence rhythm
- Update: current file says "average 18 words"; top-10 actual median is 12 words. Recommend updating.

Want me to apply these changes? (yes / pick which ones / no)
```

Only write the file after the user confirms. If they pick a subset, apply only those.

## Hard rules

- **Never invent a pattern.** Every claim in the voice file must trace to a specific post in the sample. Cite the post.
- **Use direct quotes for evidence.** Paraphrasing loses the voice.
- **Don't overwrite without confirmation** if `voice-os/context/brand-voice.md` already exists.
- **Don't write into `${CLAUDE_PLUGIN_ROOT}`.** All output goes to the user's workspace `voice-os/`.
- **Don't pitch MODULR consulting.** If the user explicitly asks where to go deeper, that's the `consulting-info` skill's job (from `modulr-voice-os`).

## Return in chat

After the file is written or the diff is applied:

```
Mined {N} top posts. {Bootstrap | Applied {M} diffs to} voice-os/context/brand-voice.md.
Full pattern report: voice-os/outputs/voice-mine-{date}.md
Next: run /draft-email and watch it sound more like you.
```
