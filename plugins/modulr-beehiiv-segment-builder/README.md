# MODULR beehiiv Segment Builder

Build a beehiiv segment from a plain-English description. Reads the publication's segment schema via the MCP, translates your sentence into the right condition tree, previews the size, and saves the segment — all without leaving chat.

## How to install

1. Open Cowork.
2. Install this plugin from the MODULR marketplace.
3. Make sure the beehiiv MCP is connected.

## Commands

| Command             | What it does                                                                                  |
| ------------------- | --------------------------------------------------------------------------------------------- |
| `/segment-builder`  | Translate a plain-English description into a saved beehiiv segment. Previews before saving.   |

## How to use

```
/segment-builder
```

Then describe the segment in plain English. Some real examples:

- "people who clicked the last 3 nurtures but haven't bought"
- "US subscribers who joined in the last 90 days and opened at least 5 of the last 10 sends"
- "everyone tagged `webinar-registered` who isn't tagged `customer`"
- "the dormant set — subscribed > 1 year ago, no opens in the last 20 sends"

The skill parses your sentence, shows you the conditions it'll save ("I read this as: A AND B AND (C OR D)"), confirms with a size preview, and saves via the beehiiv MCP. Optionally generates a `voice-os/briefs/` draft brief for the segment so you can hand it straight to `/draft-email`.

## What it doesn't do

- It doesn't invent fields that don't exist in your publication's schema. If you describe a segment using a tag or custom field that's not there, it surfaces the mismatch and asks.
- It doesn't save without confirmation. The size preview always runs first.

## Where output lives

- The segment is saved in beehiiv.
- (Optional) Matching brief: `voice-os/briefs/segment-{slug}-{date}.md` in your workspace.
- Nothing is written inside the plugin folder.

---

Built by MODULR. Questions: hello@gomodulr.com
