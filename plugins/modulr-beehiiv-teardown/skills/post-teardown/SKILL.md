---
name: post-teardown
description: Teardown a published beehiiv post — open rate, CTR, link heatmap, cohort behavior, and baseline deltas — and surface the single highest-leverage change for the next send. Triggers on "/post-teardown," "teardown this post," "why did this post underperform," "why did this post land," "review my last send," "analyze last send," or any request to debrief a published beehiiv post.
---

# /post-teardown

One-page teardown of a published beehiiv post. Always compares against a baseline. Always names a single highest-leverage change.

## Before you start

1. **The beehiiv MCP must be connected.** If not, stop and tell the user.
2. Confirm the publication. If the user has more than one (`list_publications`), ask which.

## Pick the post

Ask the user (AskUserQuestion) only if not specified:

1. The most recent confirmed send (default)
2. A specific slug or post ID
3. The single best-performing post in the last N days (for "what worked?" analysis)
4. The single worst-performing post in the last N days (for "what broke?" analysis)

## Pull the data

For the target post:
- `mcp__beehiiv__get_post` — metadata
- `mcp__beehiiv__get_post_content` — subject, preview, body (used for subject-line and length analysis)
- `mcp__beehiiv__get_post_stats` — open rate, CTR, total sent, etc.
- `mcp__beehiiv__list_post_clicks` — per-link click counts (page through all results)
- `mcp__beehiiv__list_post_subscriber_engagement` — page through to compute cohort engagement

For the baseline:
- `mcp__beehiiv__list_posts` — last 10 confirmed sends, excluding the target, sorted by send date desc
- For each: `mcp__beehiiv__get_post_stats`

## Compute

1. **Open-rate delta** — target vs. median of baseline, plus percentile rank.
2. **CTR delta** — same.
3. **Click-through-on-open delta** — CTR / open rate, to separate "they didn't open" from "they opened but didn't click."
4. **Link heatmap** — top 5 clicked links + share of total clicks.
5. **Subject-line analysis** — length (chars + words), specificity markers (numbers, names, dollar amounts), comparison to the highest-open subject lines in the baseline.
6. **Length analysis** — body word count vs. baseline median.
7. **Send-time analysis** — day-of-week and hour vs. the baseline's best/worst slots.
8. **Cohort behavior (if data available)** — which tags/segments over- or under-indexed on opens and clicks vs. the baseline average.

## Diagnose

Pick ONE primary diagnosis from this decision tree:

- Open rate down >10% vs. baseline → **the subject line / send time / from-name is the bottleneck.**
- Open rate normal, CTR down >10% → **the body / CTA / offer is the bottleneck.**
- Both up — name what worked (subject pattern, length, format) and recommend doubling down.
- Both down — name the structural issue (probably send-time, subject specificity, or audience mismatch).

Then name **the single highest-leverage change for the next send.** One sentence. Concrete. Actionable.

## Save the report

Write to `voice-os/outputs/teardown-{YYYY-MM-DD}-{slug}.md`:

```
# Teardown — {post title} — sent {send date}

## Headline

{One-sentence diagnosis: e.g. "Open rate landed 8.2pts below baseline; the subject line was the bottleneck."}

## Scorecard vs. last 10 sends

| Metric                | This post | Baseline median | Delta      | Percentile |
|-----------------------|-----------|-----------------|------------|------------|
| Open rate             | {X.X}%    | {X.X}%          | {±X.Xpts}  | {N}th      |
| CTR                   | {X.X}%    | {X.X}%          | {±X.Xpts}  | {N}th      |
| CTOR (click-on-open)  | {X.X}%    | {X.X}%          | {±X.Xpts}  | {N}th      |
| Total sent            | {N}       | {N}             | {±N}       | —          |

## Subject line

- Sent: "{subject}"
- Length: {N} chars, {N} words
- Specificity markers: {numbers / names / dollar amounts / none}
- Top baseline subjects (by open rate):
  1. "{subject}" — {X.X}% open
  2. "{subject}" — {X.X}% open
  3. "{subject}" — {X.X}% open

## Link heatmap

1. {URL} — {N} clicks ({X.X}% of total)
2. {URL} — {N} clicks ({X.X}% of total)
...

## Cohort behavior

{Which tags/segments over- or under-indexed; only include if data is available.}

## Diagnosis

{2-3 sentences. What worked, what didn't, why.}

## The highest-leverage change for next send

{One sentence. Concrete. Actionable. e.g. "Lead the next subject with a specific dollar amount — your three best baseline subjects all did."}
```

## Return in chat

Keep it short. Don't paste the full report.

```
Teardown — "{post title}" ({send date}):
  Open: {X.X}% ({±X.Xpts} vs. baseline, {N}th pct)
  CTR:  {X.X}% ({±X.Xpts} vs. baseline, {N}th pct)
  Top change for next send: {one-sentence recommendation}
  Full report: voice-os/outputs/teardown-{date}-{slug}.md
```

## Hard rules

- **Always compare against a baseline.** Never report a single number in isolation — it has no meaning without context.
- **Never invent percentages.** If `get_post_stats` doesn't return a metric, omit the row.
- **Page through paginated MCP results.** Don't truncate a heatmap because the first page was small.
- **Name ONE highest-leverage change.** Not three. Not a list. One.
- **Skip preamble.** The user asked for a teardown. Deliver it.
