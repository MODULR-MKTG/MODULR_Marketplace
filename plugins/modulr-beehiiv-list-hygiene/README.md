# MODULR beehiiv List Hygiene

Build an **exclusion segment** in beehiiv that catches the addresses quietly dragging down your open rate and deliverability: burner/disposable domains, obvious typo'd free providers, and (optionally) role-based prefixes and long-dormant subscribers.

Runs on top of the [beehiiv MCP](https://developers.beehiiv.com/). Safe to re-run as often as you like — it segments, it does not delete.

## What it does

`/build-exclusion-segment` walks your subscriber list and flags four classes of low-value address:

1. **Burner / disposable domains** — bundled list of ~3,700 known disposable email providers (mailinator, guerrillamail, 10minutemail, tempmail, yopmail, sharklasers, etc.), plus your own additions from `voice-os/context/burner-domains.md`.
2. **Typo'd free providers** — `gmial.com`, `yahooo.com`, `hotnail.com`, `gmai.com`, etc. The subscriber is almost certainly unreachable.
3. **Role-based prefixes** (optional, off by default) — `info@`, `admin@`, `noreply@`, `postmaster@`, `webmaster@`, etc.
4. **Behavior-based dead weight** (optional second pass) — subscribed > 90 days, 0 opens across the last 10 sends.

It previews counts and a sample before doing anything. On confirm, it writes the result as an **exclusion segment** in beehiiv via the MCP and saves a hygiene report to `voice-os/outputs/list-hygiene-{date}.md`.

## How to install

1. Open Cowork.
2. Install this plugin from the MODULR marketplace.
3. Make sure the beehiiv MCP is connected.

## Commands

| Command                      | What it does                                                                            |
| ---------------------------- | --------------------------------------------------------------------------------------- |
| `/build-exclusion-segment`   | Run the hygiene scan and create an exclusion segment in beehiiv.                        |

## What lives where

- **Plugin (managed, do not edit)** — `data/burner-domains.txt`, the bundled SKILL.
- **Your workspace (yours to edit)** — `voice-os/context/burner-domains.md` (your custom additions), `voice-os/context/role-prefixes.md` (your overrides for what counts as role-based), `voice-os/outputs/list-hygiene-{date}.md` (the per-run report).

When the plugin updates, the bundled domain list refreshes. Your custom additions in `voice-os/context/` are untouched.

## Safety

- The skill **never deletes subscribers.** It only creates an exclusion segment you attach to future sends.
- It **previews the count and a sample** before saving the segment.
- It is **safe to re-run** — re-running updates the same named segment (or creates a new dated one, your choice).

## Provenance of the bundled list

`data/burner-domains.txt` is a deduplicated, lowercased set of known disposable email domains. The list is meant to be augmented — drop your own additions into `voice-os/context/burner-domains.md` and the skill will read both.

---

Built by MODULR. Questions: hello@gomodulr.com
