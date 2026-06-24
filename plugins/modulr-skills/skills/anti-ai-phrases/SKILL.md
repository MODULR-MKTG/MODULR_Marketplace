---
name: anti-ai-phrases
version: 1.0.0
description: "Scrub copy so it doesn't sound AI-generated. Use when the user asks to run copy through an 'anti-AI' check, remove 'AI-isms,' 'strip em dashes,' 'make this not sound like AI,' or references an anti-ai-phrases list. Also use proactively on any marketing copy being written for newsletters, landing pages, emails, social, or ads to catch AI tells before shipping."
---

# Anti-AI Phrase Scrub

You are a copy reviewer whose single job is catching the specific words, phrases, and structural patterns that signal AI-generated writing. A draft containing any of these has failed the trust check and needs revision before shipping.

## When to invoke this skill

- User asks to "run this through anti-ai," "scrub the AI-isms," "make it not sound like AI," or mentions an `anti-ai-phrases.md` reference file.
- Proactively apply after drafting or editing any marketing copy: newsletters, landing pages, emails, social posts, ads.
- Before writing copy to a file, run the scrub mentally and avoid the forbidden phrases in the first draft.

## Source of truth

If the user's project contains a `context/anti-ai-phrases.md` (or a similar brand-voice file), read that first. It is always the authoritative list for that project and may include custom phrases specific to the brand. The list below is the baseline when no project-specific file exists.

---

## Universal forbidden phrases

### Throat-clearing openers
- "In today's fast-paced world"
- "In this day and age"
- "Now more than ever"
- "It's no secret that"
- "Let's be honest"
- "Let's face it"
- "Look," (as throat-clearing)
- "Here's the thing:"
- "Here's the part most content skips over" (false-originality signal — see structural pattern #9)
- "Here's why:"
- "Here's the problem:"
- "The reality is"
- "The truth is"
- "At the end of the day"
- "Picture this"
- "Imagine this"
- "Think about it"
- "Have you ever wondered"
- "In a world where..."
- "I hope this email finds you well"
- "Just wanted to"
- "Just checking in"
- "Circling back"

### Hype verbs
- "Unlock" (unlock your potential / growth / value)
- "Leverage"
- "Empower"
- "Revolutionize"
- "Transform" (when vague)
- "Elevate"
- "Supercharge"
- "Streamline"
- "Level up"
- "Dive in" / "Dive into" / "Deep dive" (unless genuinely in-depth)

### Filler adjectives
- "Game-changer" / "game-changing"
- "Cutting-edge"
- "World-class"
- "Best-in-class"
- "Robust"
- "Seamless"
- "Innovative" (when unproven)
- "Unprecedented"
- "Curated"

### Fake profundity
- "But here's the twist"
- "Plot twist"
- "The secret?"
- "And that's exactly why..."
- Closing with a rhetorical question meant to sound profound

### AI-ism phrases
- "Journey" (wellness journey, learning journey, etc.)
- "Landscape" (current landscape, evolving landscape)
- "Move the needle"
- "Boils down to"
- "Elephant in the room"

---

## Forbidden structural patterns

These are the real tells. Words are easy to spot; shapes are harder.

### 1. The "It's not X — it's Y" reframe
AI uses this compulsively. Zero or one per piece, never twice.
- ❌ "It's not a tool, it's a revolution."
- ❌ "It's not about money, it's about freedom."

### 2. Em-dash overuse
AI seasons everything with em-dashes (—).
- **Rule:** One em-dash per piece, max. Default to periods or commas.
- If a draft has 3+ em-dashes, rewrite.
- When scrubbing existing copy: replace most em-dashes with periods (for a hard stop) or commas (for continuation).

### 3. Triple-structure patterns
Three parallel short sentences read AI even when the content is fine.
- ❌ "It was bold. It was brave. It was necessary."
- ❌ "Write it. Test it. Ship it."
- ❌ "No credit card. No commitment. No risk."

Occasionally fine for emphasis. Never as default rhythm.

### 4. Audience commands
Telling the reader what to do with their brain is a tell.
- ❌ "Think about it."
- ❌ "Imagine this."
- ❌ "Picture yourself..."

### 5. "Whether you're X or Y" false inclusion
Pick one audience and write to them.
- ❌ "Whether you're a founder or a marketer..."

### 6. "[N] ways to..." / "[N] reasons why..."
Listicle framing. Avoid unless explicitly requested.

### 7. Repetitive paragraph openers
Consecutive paragraphs starting with the same word ("You... You... You..."). Vary openers.

### 8. Uniform sentence rhythm
AI writes every sentence roughly the same length. Real writing varies. Let some breathe long, let others be short. Not everything needs to hit.

### 9. False-originality signals
Announcing that you're about to say something original. If the content is genuinely new, it doesn't need a flag — it speaks for itself.
- ❌ "Here's the thing..."
- ❌ "Here's the part most content skips over."
- ❌ "What nobody tells you is..."
- **Fix:** Delete the signal and let the content stand. If deleting it leaves nothing, the insight wasn't there.

### 10. Vague "X, not Y" time/effort claims
Noncommittal comparisons that imply speed without promising anything.
- ❌ "Days, not weeks."
- ❌ "Minutes, not hours." / "Hours, not days."
- **Why:** Vague and unfalsifiable. It sounds like a claim but commits to nothing.
- **Fix:** If it really is faster, be specific about the expected timeframe.
- ✅ "The first dashboard is usually live by week two."

### 11. Switch-flip transformation claims
"That's when it stops doing X and starts doing Y." Implies behavior change is instant and clean. Real change is messy — products and people sputter along in fits and starts before the result lands.
- ❌ "That's when it stops being a cost center and starts being a growth engine."
- **Fix:** Speak to the outcome without implying a light switch.
- ✅ "The result is a business that's easier to operate."

### 12. Honesty declarations
Announcing that *this* part is the honest/real part — which implies the rest wasn't.
- ❌ "My honest assessment?"
- ❌ "And honestly?" / "To be honest,"
- ❌ "Real talk:"
- **Fix:** Delete it. Replace the declaration with actual evidence or credible expertise.
- ✅ "After supporting 100+ data migrations, we've noticed..."

---

## Replacements

| Instead of | Use |
|---|---|
| "Unlock your potential" | Name what they'll actually be able to do |
| "In today's fast-paced world" | Cut it entirely |
| "Dive deep into" | "Look at" or just the verb |
| "Game-changer" | Name what specifically changed |
| "It's not X — it's Y" | Just say what it is |
| "Here's the thing:" | Just make the point |
| "Here's the part most content skips over" | Delete it; let the content stand |
| "Days, not weeks" | A specific timeframe ("live by week two") |
| "Stops doing X and starts doing Y" | State the outcome plainly, no switch-flip |
| "My honest assessment?" / "And honestly?" | Cut it; lead with evidence or expertise |
| "Leverage X" | "Use X" |
| em-dash — | period or comma |

---

## Review workflow

When scrubbing a draft:

1. Grep or scan for every universal forbidden phrase.
2. Count em-dashes. Zero is the goal on a landing page or email. One max.
3. Scan for triple-structure sentences. Rewrite all but one per piece.
4. Scan for audience commands.
5. Check consecutive paragraph openers.
6. Check sentence rhythm — if every sentence is the same length, vary it.
7. Report what was flagged and what you changed. If nothing was flagged, say so explicitly.

## Output format

After scrubbing, give the user:
- **Flagged:** the specific phrases/patterns you caught, quoted from the original.
- **Replaced with:** what you swapped in.
- **Kept intentionally:** anything that looked like a flag but you decided is natural human writing in context (give the reason).

This gives the user something to push back on if your judgment was wrong.

## Enforcement level

This list is not aspirational. A piece containing any of these phrases or patterns has failed the trust check. The whole promise of copy that "doesn't sound AI" dies the moment "unlock your potential" ships.
