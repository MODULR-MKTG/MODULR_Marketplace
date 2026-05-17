# MODULR plugin marketplace

Plugins for marketers and operators who want to sound like themselves at scale.

## Install in Cowork

1. Open Cowork.
2. Add this marketplace:
   - **Marketplace URL:** `https://github.com/MODULR-MKTG/MODULR_Marketplace`
3. Browse and install any plugin in the catalog.

When new plugins are published or existing ones are updated, they propagate to your install automatically (if you have auto-sync enabled).

## What's in the marketplace

| Plugin                                 | What it does                                                                                       |
| -------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `modulr-voice-os`                      | Email drafting OS that sounds like you, not AI. Wizard setup, anti-AI gate, citation discipline.   |
| `modulr-beehiiv-list-hygiene`          | Build a beehiiv exclusion segment of burner/disposable domains and typo'd providers. One command.  |
| `modulr-beehiiv-teardown`              | Teardown a published beehiiv post vs. baseline. Open rate, CTR, link heatmap, top fix.             |
| `modulr-beehiiv-voice-mine`            | Reverse-engineer brand voice from your top-performing beehiiv posts.                               |
| `modulr-beehiiv-segment-builder`       | Plain-English → saved beehiiv segment. Parses, previews size, saves via MCP.                       |
| `modulr-beehiiv-subscriber-language`   | Mine poll and survey free-text into a structured subscriber-language file.                         |
| `modulr-beehiiv-cadence`               | Calendar, topic-gap, and next-2-weeks recommended plan for your beehiiv sends.                     |

More on the way.

## How to use a plugin

After install, type the plugin's command in any Cowork chat. For example:

```
/setup-voice-os
```

That kicks off the onboarding wizard for `modulr-voice-os`.

## Customizing without losing your work

Plugins in this marketplace follow one rule: **nothing inside the installed plugin folder is meant to be edited.** Plugin updates overwrite those files. Each plugin writes user-customizable content (your voice profile, your examples, your overrides) into a folder in your own workspace — that folder is yours and is never touched by updates. See the individual plugin's README for the exact paths.

## Repo structure

```
MODULR_Marketplace/
├── .claude-plugin/
│   └── marketplace.json    # catalog manifest
├── plugins/
│   └── modulr-voice-os/    # plugin source
└── LICENSE                 # MIT
```

## License

[MIT](./LICENSE). Use it, fork it, modify it, ship it. Attribution appreciated, not required.

## About MODULR

We help operators and marketers ship email that sounds like them. The plugins here are the tools we use, packaged so anyone can install them.

- Website: https://www.gomodulr.com
- Email: hello@gomodulr.com
- Consulting (we run your email end to end): https://www.gomodulr.com/consulting
