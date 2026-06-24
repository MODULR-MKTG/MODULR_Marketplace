---
name: musk-algorithm
version: 1.0.0
description: "Evaluate a project, system, process, codebase, product, or workflow against Elon Musk's 5-step engineering algorithm (requirements → delete → simplify → accelerate → automate). Use when the user asks to 'run this through the Musk algorithm,' 'apply the 5-step algorithm,' 'are we over-engineering this,' 'what should we delete,' 'is this premature optimization,' 'audit this process for bloat,' or wants a first-principles efficiency pass on anything being built. Works on code, infra, marketing ops, org processes, product scope — anything with steps and requirements."
---

# The Algorithm — 5-Step Engineering Audit

Evaluate anything that has requirements and process steps against a five-step ordering rule. The framework is good engineering discipline regardless of where it came from: it forces deletion *before* optimization and automation *last*, which is the opposite of how most teams (and most smart engineers) actually work.

The whole point is the **order**. Most failure comes from running it backwards — automating, accelerating, and optimizing a thing that should have been deleted or never specified in the first place.

## The five steps, in order

### 1. Make the requirements less dumb
Question every requirement. Requirements are always somewhat dumb regardless of who handed them down — and the smarter or more senior the source, the *more* dangerous, because nobody pushes back. Attach a **name, not a department**, to each requirement so there's a person to argue with. The error to hunt: a requirement everyone follows that no one can justify.

- What requirement here can't anyone defend on first principles?
- Whose name is on it? (If the answer is "the org" / "best practice" / "compliance said so" — dig.)
- Which constraint is treated as physics but is actually just convention?

### 2. Delete the part or the process step
Try to delete every part, step, or feature. The bias is to *remove*, aggressively. The calibration rule: **if you're not adding ~10% of what you deleted back in, you're not deleting enough.** Zero add-backs means you were too timid, not too smart. Deletion has to hurt a little.

- What part / step / feature / dependency / meeting / field / abstraction can be removed entirely?
- What's here "just in case" or "for flexibility we don't use yet"?
- If we deleted X and something broke, how fast would we know? (Cheap-to-revert deletions should just happen.)

### 3. Simplify or optimize
**Only now.** This is the third step, never the first — because *"the most common error of a smart engineer is to optimize a thing that should not exist."* If you optimized before steps 1 and 2, you polished work that should have been deleted. Simplify what survived deletion.

- Is anything here being optimized that should have been killed in step 2?
- What survived deletion and is now genuinely worth making simpler/faster?
- Where did "make it elegant" run ahead of "should this exist"?

### 4. Accelerate cycle time
Speed up the loop — but **only after the first three.** Speeding up a bloated, wrong, over-built process just gets you to the wrong place faster.

- Where is the loop (build/test/ship, draft/review/send, lead/qualify/close) slow?
- What's the actual bottleneck vs. the assumed one?
- Are we about to accelerate something that steps 1–3 say shouldn't run at all?

### 5. Automate
**Last.** Automating something that's wrong, bloated, or about-to-be-deleted bakes in the mistake and makes it expensive to undo.

- What's now stable, correct, and minimal enough to safely automate?
- What automation already exists that's protecting a step we should have deleted?
- The mistake to call out: anything that got automated *before* it earned steps 1–4.

## How to run the audit

1. **Get the target.** Ask what's being evaluated if it's not obvious — a codebase, a feature, a marketing workflow, an onboarding process, a data pipeline, a deck. Pull the actual artifact (read the files, the process doc, the pipeline) rather than evaluating from a description when you can.
2. **Walk the five steps in order.** For each, surface concrete findings tied to the real thing — name the specific requirement, the specific step to delete, the specific premature optimization. Generic advice fails this skill.
3. **Watch for the backwards-run.** The single most valuable output is usually catching where the team did 5→4→3 on something step 2 says to delete. Flag it loudly.
4. **Be willing to say "nothing to cut here."** If a step genuinely has no finding, say so — don't manufacture deletions to look rigorous. But default to suspicion: most projects are over-built.

## Output format

```
## Musk Algorithm Audit — <target>

**1. Requirements less dumb**
- <requirement> — defended by whom? <finding>
- ...

**2. Delete**
- <part/step/feature> → delete because <reason>. Add-back risk: <low/med/high>
- ...
- Deletion calibration: <are we cutting enough? if zero cuts, push harder>

**3. Simplify / optimize** (only what survived)
- <surviving thing> → simplify by <how>
- ⚠️ Optimizing-the-undeletable: <anything being polished that step 2 flagged>

**4. Accelerate**
- Bottleneck: <real one> → <how to speed the loop>

**5. Automate** (last)
- Safe to automate now: <thing>
- ⚠️ Automated too early: <thing that skipped steps 1–4>

### The one thing
<single highest-leverage move — almost always a deletion, not an addition>
```

Always end with **one** highest-leverage move. If you're recommending five things, you haven't applied the framework to your own answer.

## Notes

- The discipline is ordering and deletion bias. If a session devolves into "add monitoring, add tests, add docs," you've inverted it — the framework's gift is permission to *remove*.
- Source: this is Elon Musk's stated engineering process (the "5-step algorithm"). Use the framework on its merits; you don't need to endorse the source to use a good tool.
- Pairs well with a skeptical-review pass (catches unsupported claims) and a pricing-audit pass like `price-check` (catches under-pricing) — this one catches over-building.
