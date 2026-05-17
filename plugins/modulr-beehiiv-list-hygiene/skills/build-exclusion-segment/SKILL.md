---
name: build-exclusion-segment
description: Build a beehiiv exclusion segment of burner/disposable domains, typo'd free providers, and (optionally) role-based prefixes or long-dormant subscribers. Triggers on "/build-exclusion-segment," "clean my list," "burner domain segment," "list hygiene," "exclude disposable emails," "remove bogus subscribers," or any request to clean up a beehiiv subscriber list.
---

# /build-exclusion-segment

Build a beehiiv exclusion segment that catches the addresses dragging down deliverability. Never deletes. Previews before saving. Safe to re-run.

## What you need before starting

1. **The beehiiv MCP must be connected.** If not, stop and tell the user to connect it before proceeding.
2. The user's `publication_id` — call `mcp__beehiiv__get_current_user` or `mcp__beehiiv__list_publications` and confirm with the user if more than one publication exists.

## The four hygiene checks

Run these in order. Each one feeds a single combined exclusion segment.

### Check 1 — Burner / disposable domains (always on)

The plugin ships a deduplicated burner-domain list at `${CLAUDE_PLUGIN_ROOT}/data/burner-domains.txt` (~3,700 domains, one per line, lowercased, no `@` prefix).

Also read `voice-os/context/burner-domains.md` if it exists in the user's workspace — these are user additions. Same format (one domain per line, optionally prefixed with `@`, optionally suffixed with `;`).

Match any subscriber whose email's domain portion (case-insensitive, after the `@`) appears in the combined set.

### Check 2 — Typo'd free providers (always on)

A small built-in list of obvious typos for the big free providers:

```
gmial.com, gmai.com, gmaill.com, gmali.com, gmsil.com, gmial.co, gnail.com, gmail.co, gamil.com, gmal.com
yahooo.com, yahho.com, yhoo.com, yaoo.com, yahoo.co (when not yahoo.co.uk/.jp/etc), yshoo.com
hotnail.com, hotmial.com, hotmai.com, hotmal.com, hormail.com, hotmsil.com, hotamil.com
outlok.com, outloo.com, outlokk.com, outloook.com
icoud.com, iclod.com, iclooud.com
```

Match exact domain only. Do not flag legitimate variants like `yahoo.co.uk` or `gmail.co.in` — match the full domain string, not a substring.

### Check 3 — Role-based prefixes (off by default — confirm with user)

Ask the user via AskUserQuestion: **"Include role-based addresses in the exclusion? (info@, admin@, noreply@ — these are usually noise but some lists legitimately want them.)"**

If yes, match any subscriber whose local-part (before `@`) is exactly one of:

```
admin, administrator, info, noreply, no-reply, donotreply, postmaster, webmaster, hostmaster, abuse, mailer-daemon, support, contact, sales, billing, accounts, hr, help, office, root, security, marketing
```

Also read `voice-os/context/role-prefixes.md` if it exists for user overrides.

### Check 4 — Behavior-based dead weight (off by default — confirm with user)

Ask the user via AskUserQuestion: **"Add behavior-based dead weight? (Subscribed > 90 days, 0 opens across the last 10 sends. This is the most aggressive check.)"**

If yes:
1. Call `mcp__beehiiv__list_posts` with `limit=10`, `status=confirmed`, sorted by send date desc.
2. For each of those posts, call `mcp__beehiiv__list_post_subscriber_engagement` and union the set of subscribers who opened at least once.
3. Call `mcp__beehiiv__list_subscriptions` filtered to subscribers with `created > 90 days ago` and `status=active`.
4. The dead-weight set = (subscriptions older than 90 days) minus (subscribers who opened at least one of the last 10 posts).

## Process

1. **Confirm the publication.** State which publication you're working on. If ambiguous, ask.
2. **Run Check 1 and Check 2** automatically.
3. **Ask the user about Checks 3 and 4** before running them.
4. **Compute the combined exclusion set.**
5. **Preview before saving:**
   - Total subscribers scanned
   - Count by category (Burner / Typo / Role / Dormant)
   - Total unique addresses to exclude
   - Sample of 10 flagged addresses across the categories
6. **Confirm with the user via AskUserQuestion:**
   - "Save as a new exclusion segment named `MODULR Hygiene Exclusion — {YYYY-MM-DD}`?"
   - "Update an existing segment? (pick from list)"
   - "Cancel and just save the report?"
7. **On confirm**, save the segment via `mcp__beehiiv__save_segment` as an exclusion-type segment. The segment definition should encode the union of email-domain matches and (if applicable) local-part matches — use `get_segment_schema` first to confirm the supported condition format for this publication.
8. **Always write the hygiene report** to `voice-os/outputs/list-hygiene-{YYYY-MM-DD}.md` regardless of save choice — the user gets a paper trail.

## The report format

Write to `voice-os/outputs/list-hygiene-{YYYY-MM-DD}.md`:

```
# List hygiene report — {publication name} — {YYYY-MM-DD}

## Summary

| Category                       | Count    |
|--------------------------------|----------|
| Total active subscribers       | {N}      |
| Burner / disposable            | {N}      |
| Typo'd free provider           | {N}      |
| Role-based (if run)            | {N}      |
| Dormant > 90d, 0 opens (if run)| {N}      |
| **Total flagged for exclusion**| **{N}**  |

## Segment

- Name: `{segment name}`
- ID: `{segment id from save_segment response}`
- Type: exclusion
- Status: saved / not saved

## Sample of flagged addresses (first 25)

- burner: {email} ({domain})
- typo:   {email} ({domain})
- role:   {email}
- dormant:{email} (subscribed {date}, 0 opens of 10)
...

## Top burner domains in this list

1. {domain}: {count}
2. {domain}: {count}
...

## Recommended next step

Attach this exclusion segment to your next send. Re-run /build-exclusion-segment monthly to catch new arrivals.
```

## Hard rules

- **Never delete subscribers.** Only create exclusion segments.
- **Always preview before saving.** The user must see the count and sample.
- **Never write to `${CLAUDE_PLUGIN_ROOT}`.** All user output lives in their workspace `voice-os/outputs/`.
- **Match the full domain string** (not a substring) for the typo check, to avoid false positives like flagging `yahoo.co.uk` because it contains `yahoo.co`.
- **Lowercase both sides before comparing.** Email addresses are case-insensitive in the local-part by convention (beehiiv normalizes), and definitely case-insensitive in the domain.
- **If the MCP returns paginated results, page through all of them** before reporting counts. Don't report partial numbers as if they were the total.

## Output discipline

When the run finishes, return a short summary in chat (not the full report — that goes to the file):

```
Scanned {N} subscribers. Flagged {M} for exclusion ({burner} burner, {typo} typo, {role} role, {dormant} dormant).
Saved exclusion segment: {segment name} ({segment id}).
Full report: voice-os/outputs/list-hygiene-{date}.md
```

If the user said "cancel," return:

```
Scanned {N} subscribers. {M} would have been excluded. No segment saved.
Full report: voice-os/outputs/list-hygiene-{date}.md
```
