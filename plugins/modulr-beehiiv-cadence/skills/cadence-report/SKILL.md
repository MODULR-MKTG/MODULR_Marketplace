---
name: cadence-report
description: Build a newsletter cadence + topic-gap report from the last 60-90 days of beehiiv sends, plus a specific next-2-weeks recommended plan (date, send time, format, topic, offer anchor). Triggers on "/cadence-report," "what should I send next," "newsletter calendar," "send schedule," "topic gaps," "cadence audit," "next 2 weeks of sends," or any request to plan upcoming beehiiv content.
---

# /cadence-report

Calendar + performance + topic-gap + next-2-weeks plan. Output is a brief `/draft-email` can read directly.

## Before you start

1. **The beehiiv MCP must be connected.** If not, stop and tell the user.
2. Confirm the publication.

## Configure

Ask via AskUserQuestion only if not specified:

1. **Window** — last 30 / 60 / 90 days (default 60)
2. **Plan horizon** — next 1 / 2 / 4 weeks (default 2)

## Pull the data

1. `mcp__beehiiv__list_posts` — all confirmed sends in the window. Page through.
2. For each: `mcp__beehiiv__get_post_stats`. Capture: send date, send time, open rate, CTR, total sent.
3. For each: `mcp__beehiiv__get_post` to capture format/tag metadata (newsletter / promo / announcement / nurture / etc.) and `mcp__beehiiv__list_content_tags` if needed for content-tag mapping.
4. Read `voice-os/context/offers.md` if present — this is the offer rotation reference.
5. Read `voice-os/context/audience.md` if present — for segment context in recommendations.

## Analyze

### What shipped

- Total sends in the window
- Sends per week (with variance — was the cadence steady or bursty?)
- Format mix (% newsletter / promo / nurture / announcement)
- Topic distribution (group by content-tag or by manual topic clustering on titles + first 100 words)

### What worked

- **By day-of-week** — median open rate, median CTR, sample size per day
- **By send hour (in the publication's configured timezone)** — same
- **By format** — same
- **By topic cluster** — same
- **By subject-line pattern** — number-led / question / direct quote / contrarian / etc., bucketed and ranked by open rate

Flag any cell with sample size < 3 as "low confidence — directional only."

### What's missing

- **Offer rotation gap** — for each offer in `voice-os/context/offers.md`, when was it last referenced? Flag any offer not mentioned in the window as "stale."
- **Format under-rotation** — if a format with strong baseline performance shows up < 20% as often as the modal format, flag it.
- **Subject-line under-rotation** — patterns that scored best but haven't been used in 14+ days.
- **Topic gaps** — topics the audience has clicked on heavily (from this run's clicks data + any installed `voice-os/context/audience-language.md`) but haven't been the lead topic recently.

## Recommend next N weeks

For each slot in the plan horizon (using the modal cadence — if the user typically sends 2/week, recommend that many), produce ONE specific recommendation:

```
{Day, date}
Send time: {hour} {tz}  ← based on best-performing slot
Format: {format}        ← based on best-performing format + rotation gap
Topic: {topic}          ← specific, not "newsletter"
Offer anchor: {offer | none}  ← from offers.md if relevant
Subject pattern to try: {pattern} ← e.g. "specific-number-led" or "direct-question"
Why this slot: {1 sentence}
```

Don't recommend a slot you can't justify with data. If you don't have a confident pick for a slot, say so:

```
{Day, date}
Slot intentionally open. Sample size for this day-of-week is too low to recommend confidently — recommend filling with a low-risk nurture or skipping.
```

## Write the brief

Write `voice-os/briefs/cadence-{YYYY-MM-DD}.md`:

```
# Cadence plan — {publication} — next {N} weeks — generated {date}

## The plan

### Send 1 — {Day, date}
- Send time: {hour tz}
- Format: {format}
- Topic: {topic}
- Offer anchor: {offer or "none"}
- Subject pattern: {pattern}
- Why: {1 sentence}

### Send 2 — {Day, date}
...

## What to feed /draft-email

For each send, the inputs are ready:
- Format
- Topic / angle
- Audience segment (default = "primary" unless noted)
- Offer reference (if promo)

## Notes

- {Anything important — e.g. "skip Thursday this week, conflict with X."}
- {Stale offers worth surfacing.}
```

## Write the full report

Also write `voice-os/outputs/cadence-{YYYY-MM-DD}.md`:

```
# Cadence report — {publication} — {window} — {date}

## What shipped

| Week     | Sends | Formats               | Topics                |
|----------|-------|-----------------------|-----------------------|
| W of M/D | {N}   | {format counts}       | {topic clusters}      |
...

Total: {N} sends, {N}/week average ({stdev} stdev).

## What worked

### By day-of-week
| Day | Sends | Median open | Median CTR |
|-----|-------|-------------|------------|
...

### By send hour
| Hour ({tz}) | Sends | Median open | Median CTR |
|-------------|-------|-------------|------------|
...

### By format
| Format | Sends | Median open | Median CTR |
|--------|-------|-------------|------------|
...

### By subject-line pattern
| Pattern | Sends | Median open |
|---------|-------|-------------|
...

## What's missing

### Stale offers (not referenced in window)
- {offer name} — last mentioned: {date or "never"}
- ...

### Under-rotated formats
- {format} — used {N} times, baseline performance {open}% — recommend using {target}× more
- ...

### Topic gaps
- {topic} — high engagement signal, no lead send in {N} days

## Recommended next {N} weeks

[mirror of the brief]

## Confidence flags

- Day-of-week recommendations: {high / medium / low confidence based on sample sizes}
- Send-hour recommendations: {same}
- Topic recommendations: {same}
```

## Hard rules

- **Flag low sample sizes.** Don't recommend "send on Tuesday at 7am" off two data points. Say so.
- **Read `voice-os/context/offers.md` before recommending offer anchors.** Don't invent offers.
- **Never invent a topic gap** that isn't supported by click or engagement data.
- **Use the publication's configured timezone** for all hour-of-day analysis. Surface the timezone in the report so it's not ambiguous.
- **Don't write into `${CLAUDE_PLUGIN_ROOT}`.** Output lives in `voice-os/briefs/` and `voice-os/outputs/`.
- **Don't pitch the MODULR workshop.** That's `workshop-info`'s job.

## Return in chat

```
Cadence report — last {window}, {N} sends.
Best day: {day} ({open}% median open). Best hour: {hour tz}. Best format: {format}.
Stale offers: {N}. Under-rotated formats: {N}.
Next {N} weeks: {N} sends recommended (specifics in brief).
Brief: voice-os/briefs/cadence-{date}.md
Full report: voice-os/outputs/cadence-{date}.md
```
