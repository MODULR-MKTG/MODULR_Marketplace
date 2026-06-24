---
name: email-engagement-analysis
version: 1.0.0
description: "Run a deep-dive engagement analysis on a client's email program and produce a branded PDF report. Use when the user wants to analyze opens/clicks/CTOR over time, evaluate subject-line performance, audit list growth, compare email formats, or build a report 'for [client]' to present to leadership. Works across any ESP (ActiveCampaign, HubSpot, Klaviyo, Mailchimp, Customer.io, Iterable, etc)."
---

# Email Engagement Analysis

You are doing a serious analysis of a client's email program with the goal of producing a branded, presentation-quality PDF that reframes how leadership thinks about email performance. The deliverable should make leadership say "holy shit, this wasn't even part of the agreement." Status reports get ignored. Reframes get forwarded.

## When to invoke this skill

- User asks to "analyze [client]'s email" / "look at engagement" / "build a report on email"
- User wants to evaluate subject-line performance, list growth, format comparisons
- User mentions a specific client and email metrics (opens, clicks, CTOR, unsubs)
- User asks for a "deep-dive" or wants something to share with a stakeholder
- User wants to compare two email cadences (newsletter vs reel, etc.)

## The core insight to anchor on

Almost every client thinks they have an engagement problem. They actually have a **measurement problem**. Open rate has been progressively destroyed by Apple Mail Privacy Protection (2021–2024 rollout). It conflates real opens with prefetch opens, and the mix shifts year over year. As a list scales, the percentage falls mathematically even when raw engagement rises.

**The strongest analysis reframes the question.** "Open rate is down" is the wrong question. "Are people actually engaging?" is the right one. Lead with click rate, CTOR, and absolute unique clicks — not open rate.

## What you need from the client

Three pulls, all available via every major ESP's API:

### 1. Per-campaign metrics
For every send: `id`, `name`, `send_date`, `send_amt` (recipients), `unique_opens`, `unique_clicks`, `unsubscribes`, `bounces` (hard + soft), `replies` (if available). Pull `subject` and ideally `preheader` and rendered `html` body.

### 2. Subject + body content joined to campaigns
Some ESPs put subject on the campaign object; some put it on a separate "message" or "template" object linked by `message_id`. Pull both and join client-side. Body HTML lets you compute content features (length, link count, image count, button count).

### 3. List growth data
Per-list `subscribed_at` and `unsubscribed_at` timestamps. Reconstruct the historical curve client-side. Most ESPs expose this through a "list memberships" or "subscriptions" endpoint.

**Important caveat:** Many ESPs purge unsubbed contacts from the membership list, so your historical *unsub* curve will be incomplete. Get true unsub volume by summing the per-campaign `unsubscribes` field across all sends.

## Computed metrics — what actually matters

| Metric | Formula | What it tells you |
|---|---|---|
| Open rate | unique_opens / send_amt | Politically expected. Practically degraded by MPP. Useful within a category and tight time window. |
| Click rate | unique_clicks / send_amt | Less corrupted by MPP. Better signal for almost any question. |
| **CTOR** | unique_clicks / unique_opens | **The cleanest signal of content quality.** Strips deliverability and audience-warmth effects. |
| Unsub rate | unsubscribes / send_amt | List health. Falling unsub on a growing list is rare and counter-intuitive (good sign). |
| **Absolute unique opens/clicks** | (raw counts per send) | The number leadership should actually care about. "4,800 humans opened this" beats "23%". |

**Rule:** Always include absolute numbers alongside rates. "Open rate is down 14pp but median unique clicks per send went from 272 to 1,623" is the headline-finding shape.

## The five analysis pitfalls — avoid all of them

These are the traps that turn a real analysis into a misleading one. Avoiding all five separates a deliverable that lands from one that gets pushback.

### 1. Simpson's paradox / audience confounding
A "subject lines that drive engagement" analysis blended across all campaigns will surface patterns that are actually warm-audience effects.

*Example:* `%FIRSTNAME%` personalization shows +14pp open rate lift in naive analysis. But the only sends using it are nurture sends to warm registrants. The audience is doing the work, not the personalization.

**Avoid by:** Always restrict subject-feature comparisons to *within a single campaign category*. Newsletter to newsletter only. Reels to reels only. Never let a 591-recipient warm cert offer dilute a comparison against 24K newsletter blasts.

### 2. The open-rate trap
Apple MPP registers an "open" the moment Apple's servers prefetch the email — whether a human ever sees it or not. Mix shifts unpredictably year-over-year. Add list growth and the rate falls even when raw engagement rises.

A 30% open rate on 8K sends = 2,400 humans. A 23% open rate on 21K sends = 4,830 humans. Lower rate, twice the reach.

**Avoid by:** Lead the report with absolute clicks, CTOR, and net subscribers. Demote open rate. Explicitly call out MPP and list-size dilution as confounds.

### 3. Confounding format with audience
When a client has multiple cadence sends (newsletter + reel + podcast), direct comparison is tempting: "the reel underperforms." But unless audience size is comparable, you can't tell if format is the problem or audience composition is.

**Avoid by:** Restrict format-vs-format comparisons to sends with similar audience size (e.g. both ≥5,000 recipients). Note the n in every comparison. If clean apples-to-apples isn't possible, say so.

### 4. Means vs medians
Email metrics are right-skewed — small-list tests pull means way up. A blended "average open rate" across hundreds of campaigns is dominated by tiny warm sends.

**Avoid by:** Always report medians. Mention this explicitly in methodology. If you do report a mean, name it as a mean.

### 5. Survivorship in the list
The current list is not the historical list. Anyone who unsubscribed before today isn't in the `subscribers` table anymore in most ESPs.

**Avoid by:** Reconstruct from contact subscription timestamps (preserved per-contact even after unsub). For unsub volume, sum per-campaign `unsubscribes`. Never claim a historical list size from a snapshot.

## The reframe pattern

Every email engagement analysis follows this arc:

1. **The metric the client is worried about.** ("Open rate is down.")
2. **The thing that metric is actually measuring.** ("MPP + list dilution + audience cooling, not content quality.")
3. **The metrics that show what's happening.** (CTOR up, absolute clicks up, unsub down.)
4. **The real story.** ("Engagement is the strongest it's ever been.")
5. **The thing they should actually invest in.** (Whatever the data points to as highest leverage.)

If your analysis doesn't reframe step 1 into something more useful, you're doing reporting, not analysis.

## Finding the headline finding

There's always one number that's the holy-shit moment. Lead the report with it. The shape of a strong headline finding:

- "Median unique clicks per send went from 272 → 1,623 over two years. 6× growth."
- "Q1 alone added more subscribers than all of last year."
- "Newsletter CTOR is 23%. Reel CTOR is 11%. Same audience size."

Look for finding-shapes like:
- A ratio that flipped or grew dramatically
- An absolute number that contradicts a percentage drop
- A within-category comparison where one variant dominates
- A time-series showing acceleration (not just growth)
- A counter-intuitive correlation (unsub rate falling as list grows)

## Categorize before comparing

Before any cross-campaign analysis, classify every campaign into a content type via regex on `name + subject`. Always spot-check.

Typical categories:
- **Newsletter** (weekly/monthly cadence, big audience)
- **Friday Reel / video drop / podcast** (parallel cadence, big audience)
- **Webinar invite** (event promotion)
- **Certification / lead magnet offer**
- **Masterclass / live event**
- **Local event** (city-specific, small warm list)
- **Partner / affiliate** (e.g. ATD, SHRM, partner publication)
- **Follow-up** (post-event, post-purchase)
- **Nurture** (mid-funnel, often personalized)
- **System** (welcome, opt-in, password reset)

Per-category benchmarks table goes early in the report. Lets readers ground every finding in "compared to what."

## Subject-line analysis approach

The temptation is regression, ML, NLP. Almost always overkill for an exec deliverable. Stick to **binary subject features**:

- Has question mark
- Has emoji
- Has personalization token (`%FIRSTNAME%`, `{{first_name}}`, etc.)
- Has number (digit anywhere in subject)
- All-caps word count
- Contains brackets `[...]`
- Subject length buckets (<30, 30–49, 50–69, 70+)
- First word (lowercased, stripped punctuation)

For each feature, compute median open rate WITH vs WITHOUT, **within a single category**. Require n≥5 in each group. Report lift in percentage points (more interpretable for execs than multipliers).

## Things to call out as NOT supported

In every analysis there will be intuitively-appealing claims the data doesn't support. Calling them out builds credibility. Common ones:

- "Subject length matters" — usually doesn't, in any consistent way
- "Personalization always helps" — only proven if tested at scale; small-sample wins are warm-audience confounds
- "[Brackets] kill open rate" — usually a category effect, not a bracket effect
- "Emoji boost open rate" — mixed evidence, almost never significant in small samples

A "What the data does NOT support" section is the single highest-credibility move in the deliverable.

## Skepticism flags

After the lift table, include a "what NOT to learn from" section listing the highest-open-rate sends that are actually warm/segmented audiences. The rule: **any send with open rate >45% AND audience <2,000 is almost always a warm or segmented list.** Use the result to learn what worked *for that audience*. Don't generalize to the main list.

## Thorough, not long (the governing rule)

This report is **thorough but short, skimmable, and easy to retain.** The page list below is a menu of jobs to cover, **not a length target.** A report that says everything in 6 pages beats one that pads to 11. Apply the skim test: a leader who reads only the headlines, big-number callouts, and bolded takeaways should get the complete story and be able to act. Grade-5 sentences (short, one idea each, everyday words) — but keep the metric terms the client uses daily (open rate, CTOR, MPP). Cut any sentence that doesn't change a decision. (Pair with the `anti-ai-phrases` skill for a final phrasing scrub.)

## Report structure — cover these jobs (length follows, isn't set)

Include the sections the data earns, drop the ones it doesn't:

1. **Cover** — punchy contrarian headline, three big numbers, brand styling
2. **Executive summary** — 5 numbered findings + "for leadership" callout
3. **The reframe** — open rate trap with the misleading chart followed by the real chart
4. **Detail / supporting table** — full year-over-year metrics with quartiles
5. **List growth** — chart + big numbers + recent quarters table
6. **Format A vs Format B** — head-to-head bar chart + callout for the biggest finding
7. **Subject leaderboards** — top 5 / bottom 5 by category in two-column layout
8. **Subject patterns** — within-category lift table + "what data does NOT support"
9. **Skepticism flags** — "what NOT to learn from" with the small-list-warning rule
10. **Recommendations** — 5 cards, biggest leverage first, each tied to a finding
11. **Methodology** — data sources, why we trust the comparisons, known limitations, file inventory

Each page does one job. Resist cramming — and resist padding. If a section's data doesn't change what leadership should do, cut the section, don't pad it to fill a page.

## Page design rules that work

- Brand-color accents on a primary color, warm off-white background tints (or whatever the client/agency brand uses)
- Big-number callouts (3 across) for headline metrics — exec eyes go straight to them
- Numbered tldr-bullets with colored markers — readable in 30 seconds
- "Callout" boxes with an eyebrow label for important framing notes
- Recommendation cards with circled numbers — feels like an action plan, not a memo
- All charts as inline SVG — no Chart.js dependency, no rendering lag, perfect print fidelity
- Use medians (visualized as bars or lines), never error bars or confidence intervals (too academic)
- Caption every chart with a one-sentence interpretation, italicized

## Tooling stack

A portable pipeline that works for any client/ESP:

- **Python stdlib** for ESP API pulls (urllib + json, no external deps)
- **CSV outputs** for every analysis layer (categorized.csv, list_growth.csv, etc.) — client should be able to verify any number
- **Inline SVG charts** generated by hand (~150 lines of Python) — easier to brand-style than matplotlib or Chart.js
- **HTML report** with print-stylesheet CSS (`@page` rules, `page-break-before: always`)
- **Headless Chrome for HTML→PDF**: `chrome --headless --disable-gpu --print-to-pdf=out.pdf file:///path/to/report.html`
- **pdftoppm** for PDF→PNG visual QA before delivering

## Time budget

For a similar account size (200–500 campaigns, 1–25K subscriber list):

- Data pull: 1–2 hours (write the script, debug API quirks, paginate)
- Analysis: 2–3 hours (categorization, metric computation, exploration)
- Report writing: 3–4 hours (find the headline, draft copy, structure)
- Design + iteration: 2–3 hours (charts, pagination, brand styling, AI-phrasing scrub)
- **Total: ~10 hours from API token to delivered PDF**

Most of the time is in finding the headline finding and writing copy that lands.

## Pitfalls when generating the deliverable

- **Charts overflow the page.** Use `page-break-before: always` on each `.page` div with `height: 11in; overflow: hidden`. Render with pdftoppm to verify each page fits before sending.
- **Chart x-axis labels overlap.** Show only ~5 evenly spaced labels max. Skip labels that would land within 70px of an already-placed label.
- **Y-axis labels show "0%" everywhere.** Float values formatted with `int()` then `:.0%` round to zero. Pass floats directly to the formatter for percentages, ints for counts.
- **PDF too big to email.** Embedded PNG logos balloon the file. Use a CSS-drawn brand mark (e.g. a single `<span>` with `border-radius` and a letter inside) — drops the file by ~80%.
- **AI phrasing leaks into copy.** Search the source for: "leverage", "deep-dive", "highest-leverage", "ensure", "harness", "robust", "comprehensive", "deserves identification", "the reality is", "to be clear". All AI tics. Replace with direct prose. (Use the `anti-ai-phrases` skill for a more thorough scrub.)
- **The numbers don't match the source.** Triple-check before sending. Run the analysis script with `print()` statements showing every reported number and compare to the report copy by hand.
- **The cover headline doesn't land.** Make it specific (numbers, not adjectives), contrarian (the opposite of what they expected), and three-line max. "The list is up 24×. The clicks are up 6×. The story isn't the open rate." beats "An analysis of email engagement trends."

## Reference implementation

Build the pipeline as a small set of scripts you can copy and adapt per client:

- `pull_engagement_data.py` — ESP API → CSV pull (campaigns, messages, list memberships)
- `categorize_and_analyze.py` — categorization + per-category benchmarks + subject lift analysis
- `build_html_report.py` — HTML/SVG report generator + headless Chrome PDF render

Brand colors and report copy change per client; the pipeline doesn't.

## Workflow when invoked

1. **Confirm scope.** What ESP? Which client? Is the goal a deliverable for an exec, or analysis for the user? Do they want a PDF, or just numbers?
2. **Get credentials.** API key, account URL/subdomain. Read-only is fine.
3. **Pull the three datasets** (campaigns, messages, list growth) into CSVs.
4. **Categorize and benchmark** per category.
5. **Find the headline finding.** This is the most important step. Spend time here.
6. **Draft the report.** Follow the 10–11 page structure. Adapt to what the data says.
7. **Triple-check every number** against source CSVs.
8. **Render and visually QA** every page with pdftoppm before delivering.
9. **Scrub AI phrasing** in a final pass.
10. **Deliver as PDF** + the underlying CSVs alongside it.

The user will usually want the PDF dropped into a shared client folder. Confirm the folder before uploading.
