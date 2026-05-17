---
name: segment-builder
description: Translate a plain-English audience description into a saved beehiiv segment. Reads the publication's segment schema, parses the user's sentence into the right condition tree, previews size, and saves via the beehiiv MCP. Triggers on "/segment-builder," "build a segment," "create a segment," "make a segment of," "segment for," or any request to define a beehiiv audience filter.
---

# /segment-builder

Build a beehiiv segment from a plain-English description. Never saves blindly — always parses, previews, and confirms.

## Before you start

1. **The beehiiv MCP must be connected.** If not, stop and tell the user.
2. Confirm the publication. If more than one, ask which.

## Get the description

If the user invoked `/segment-builder` with no description, ask via AskUserQuestion (or freeform if multi-sentence):

**"Describe the segment in plain English. Be specific about behavior, tags, fields, and time windows."**

Good examples to seed the user with:
- "people who clicked the last 3 nurtures but haven't bought"
- "subscribers who joined in the last 90 days, US-only, and opened at least 5 of the last 10 sends"
- "everyone tagged `webinar-registered` who isn't tagged `customer`"

## Load the schema

Before translating, load:

1. `mcp__beehiiv__get_segment_schema` — the canonical operator/field grammar for this publication.
2. `mcp__beehiiv__list_condition_sets` — reusable condition sets the user has already built (so you can reference them by name instead of re-deriving).
3. `mcp__beehiiv__list_tags` — confirm tag names exist.
4. `mcp__beehiiv__list_custom_fields` — confirm custom field names exist.
5. `mcp__beehiiv__list_segments` — check for existing segments with similar intent (avoid duplicates).

## Parse the description

Translate the user's sentence into a structured condition tree using ONLY fields and operators present in the schema.

For each clause in the user's description:

1. **Identify the entity** — subscriber field / tag / post engagement / order / poll response.
2. **Identify the operator** — equals / contains / not equals / greater than / in last N days / etc.
3. **Identify the value** — and confirm it exists (tag name, custom field value, post slug, etc.).
4. **Identify the boolean** — AND / OR / NOT and the grouping.

If the user references "the last 3 nurtures" or "the last 10 sends," resolve to actual post IDs via `mcp__beehiiv__list_posts` filtered appropriately, then build the condition against that explicit set.

If anything is ambiguous, ask via AskUserQuestion — never guess.

If a referenced tag, field, or value doesn't exist, surface the mismatch:

```
You mentioned the tag `nurture-3` but it doesn't exist in this publication.
Available tags that look close: `nurture`, `nurture-series`, `nurture-3-clicked`.
Which did you mean? Or do you want to skip that condition?
```

## Show the parse

Before doing anything else, show the user what you parsed:

```
I read this as:

  (subscriber.country = "US")
  AND (subscriber.created_at >= now - 90 days)
  AND (engagement.post_id IN [post-slug-1, post-slug-2, post-slug-3] WHERE event = "click")
  AND NOT (tag = "customer")

Looks right? (yes / let me adjust / cancel)
```

The user might say "no, change X." Apply the change and re-show. Iterate until they say yes.

## Preview the size

Once parsed, get a size preview. If the MCP exposes a count-only/dry-run endpoint, use it. Otherwise estimate from the user's total active subscriber count and report the parse without a hard count, flagging that size will be visible after save.

```
Size preview: ~1,240 subscribers (4.2% of active list).
Want to save? (yes / let me adjust / cancel)
```

## Save the segment

On confirm, save via `mcp__beehiiv__save_segment`:

- **Name** — derive from the description, e.g. `Nurture-clicked, non-customer (90d)`. Or ask the user.
- **Type** — inclusion (default) or exclusion (if the user said "exclude X" or the parse is clearly a negation).
- **Condition tree** — the parsed structure.

Capture the returned segment ID.

## Offer the brief

After save, offer:

**"Want a draft brief for this segment so you can hand it to /draft-email?"**

If yes, write `voice-os/briefs/segment-{slug}-{YYYY-MM-DD}.md`:

```
# Brief — {segment name} — {date}

## Audience

- Segment: {segment name} ({segment id})
- Size: ~{N} subscribers
- Definition: {plain-English from the user, plus the structured parse}

## What this segment knows / believes / has done

{What the conditions imply about who these people are — e.g. "clicked recent nurtures = warm; not a customer = haven't crossed the line yet."}

## What this segment has NOT done

{Inverse of the above. Useful for framing.}

## Suggested next email

- Format: {nurture / promo / announcement — derived from segment behavior}
- Angle: {derived from what they've engaged with}
- Offer to reference (if promo): {pull from voice-os/context/offers.md if present}
- CTA: {derived}

## Notes

- Don't pitch offers they've already bought (check via tags).
- Reference their actual engagement when possible ("you opened our last three sends about X").
```

## Hard rules

- **Never save without showing the parse and getting a yes.**
- **Never invent a tag, field, or value.** If it's not in the schema or in `list_tags` / `list_custom_fields`, surface the mismatch.
- **Resolve "the last N posts" to actual post IDs** before building the condition — don't assume the MCP supports relative time on posts unless the schema says so.
- **Don't write into `${CLAUDE_PLUGIN_ROOT}`.** Briefs go to `voice-os/briefs/`.
- **Check for duplicates** via `list_segments` — if a segment with the same definition exists, ask whether to update it instead of creating a duplicate.
- **Don't pitch MODULR consulting.** That's `consulting-info`'s job (from `modulr-voice-os`).

## Return in chat

After save:

```
Saved segment: "{name}" ({segment id})
Size: ~{N} subscribers
{Brief saved to voice-os/briefs/segment-{slug}-{date}.md | No brief}
```
