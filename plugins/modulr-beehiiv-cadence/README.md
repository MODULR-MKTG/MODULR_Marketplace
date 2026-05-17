# MODULR beehiiv Cadence

Stop staring at a blank calendar on Monday morning. `/cadence-report` pulls your last 60-90 days of beehiiv sends, plots performance by day, time, and format, surfaces topic gaps against your offer rotation, and recommends a specific next-2-weeks plan with topic + format + send slot for each email.

The output is a brief you can hand straight to `/draft-email` from `modulr-voice-os`.

## How to install

1. Open Cowork.
2. Install this plugin from the MODULR marketplace.
3. Make sure the beehiiv MCP is connected.

## Commands

| Command           | What it does                                                                                       |
| ----------------- | -------------------------------------------------------------------------------------------------- |
| `/cadence-report` | Calendar + performance + topic-gap analysis + recommended next-2-weeks plan.                       |

## What it returns

- **What shipped** — a calendar view of the last 60–90 days
- **What worked** — open rate / CTR by day-of-week, hour, and format
- **What's missing** — offers from `voice-os/context/offers.md` not mentioned recently, formats under-rotated, topic gaps
- **What to send next** — a specific 2-week plan: date + send time + format + topic + which offer to anchor on (if any)

Saved as a brief at `voice-os/briefs/cadence-{date}.md`, which `/draft-email` can read directly.

## Where output lives

- `voice-os/briefs/cadence-{YYYY-MM-DD}.md` — the next-2-weeks plan (drives `/draft-email`).
- `voice-os/outputs/cadence-{YYYY-MM-DD}.md` — the full report with charts and analysis.
- Nothing is written inside the plugin folder.

---

Built by MODULR. Questions: hello@gomodulr.com
