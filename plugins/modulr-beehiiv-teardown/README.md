# MODULR beehiiv Teardown

Run a one-page teardown of any published beehiiv post. Pulls stats via the beehiiv MCP, compares to a rolling 10-send baseline, surfaces what worked / what didn't, and names the single highest-leverage change for the next send.

Replaces "stare at the beehiiv dashboard for 20 minutes and guess."

## How to install

1. Open Cowork.
2. Install this plugin from the MODULR marketplace.
3. Make sure the beehiiv MCP is connected.

## Commands

| Command            | What it does                                                                                       |
| ------------------ | -------------------------------------------------------------------------------------------------- |
| `/post-teardown`   | Teardown a published post — open rate, CTR, link heatmap, baseline deltas, top fix recommendation. |

## How to use

```
/post-teardown
```

The skill will ask which post (defaults to most recent), pull stats, build a baseline from the last 10 sends, and save a report to `voice-os/outputs/teardown-{date}-{slug}.md`.

You can also point it at a specific post:

```
/post-teardown the-friday-newsletter
```

## What it returns

- Open rate vs. baseline (delta + percentile)
- CTR vs. baseline (delta + percentile)
- Top clicked links (heatmap)
- Cohort behavior (segments that over/under-indexed)
- Subject-line analysis vs. recent subjects
- **The single highest-leverage change** for the next send

## Where output lives

- Per-run report: `voice-os/outputs/teardown-{YYYY-MM-DD}-{slug}.md` in your workspace.
- Nothing is written inside the plugin folder.

---

Built by MODULR. Questions: hello@gomodulr.com
