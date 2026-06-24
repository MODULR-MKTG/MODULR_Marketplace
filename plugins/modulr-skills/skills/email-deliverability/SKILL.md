---
name: email-deliverability
version: 1.0.0
description: "Diagnose and fix why email isn't landing in the inbox. Audits SPF, DKIM, and DMARC with live DNS lookups; interprets Postmaster Tools spam rates; runs the domain/IP warm-up and deferral-recovery playbook; and checks compliance with the Gmail, Yahoo, and Microsoft bulk-sender rules. Use when the user says 'emails going to spam,' 'deliverability audit,' 'why am I not landing in the inbox,' 'set up SPF/DKIM/DMARC,' 'Gmail bulk sender rules,' 'one-click unsubscribe,' 'spam rate too high,' 'warm up a domain,' or mentions Postmaster Tools. This is defensive deliverability for opt-in senders — it does not help send unsolicited or cold email."
---

# Email Deliverability — Diagnose & Fix

You diagnose why a sender's email isn't reaching the inbox and tell them the exact fix, in the right order. You don't hand back a generic checklist — you check the real domain, read the real numbers, and rank the fixes by impact. Authentication first, complaint rate second, warm-up third. Almost every "we're going to spam" problem is one of those three, in that order.

This skill is for **opt-in senders** improving deliverability of mail people asked for. It is not for sending cold or unsolicited email, and it will not help evade spam filters for mail recipients didn't consent to.

## When to invoke

- "Our emails are going to spam" / "why aren't we landing in the inbox"
- "Run a deliverability audit on [domain]"
- "Set up / check SPF, DKIM, DMARC"
- "Are we compliant with the Gmail / Yahoo bulk sender rules?"
- "Our spam rate / complaint rate is too high"
- "Warm up a new domain or IP" / "we're getting deferrals (421)"
- Any mention of Postmaster Tools, List-Unsubscribe, or DMARC alignment

## What you need from the user (ask only what's missing)

1. **Sending domain** — the domain in the `From:` address (e.g. `mail.example.com` or `example.com`). Required for the auth audit.
2. **ESP / sending platform** — Mailchimp, HubSpot, Klaviyo, SendGrid, Google Workspace, etc. Tells you which DKIM selector to look for and which SPF include to expect.
3. **Volume** — roughly how many messages/day to a single provider (Gmail, Yahoo). The **5,000/day to one provider** line decides which rules apply.
4. **Postmaster Tools spam rate** (if they have it) — the single most important health number. If they don't have it set up, that's finding #1.

## The diagnostic flow

Run these in order. Each produces a pass/fail and a concrete fix. Don't skip ahead — a perfect warm-up on a domain with no DMARC still goes to spam.

### Step 1 — Authentication audit (live DNS lookups)

Run the actual lookups. Use `dig` (or `nslookup` on Windows). Report each record as ✅ pass / ⚠️ weak / ❌ missing, with the exact fix.

**SPF** — authorizes which servers may send for the domain.
```
dig +short TXT example.com | grep -i spf
```
- ❌ No `v=spf1` record → publish one that includes the ESP (e.g. `v=spf1 include:_spf.google.com ~all`).
- ⚠️ More than ~10 DNS lookups in the chain → SPF will `permerror` and fail. Flatten or reduce `include:`s.
- ⚠️ Ends in `+all` → wide open. Use `~all` (softfail) or `-all` (hardfail).
- ✅ Has `v=spf1`, includes the real ESP, ≤10 lookups, ends `~all`/`-all`.

**DKIM** — cryptographically signs the message. You must know the **selector** (the ESP sets it). Check the per-ESP table in `references/auth-records.md` if the user doesn't know it.
```
dig +short TXT <selector>._domainkey.example.com
```
- Common selectors: Google Workspace `google`, Mailchimp `k1`/`k2`/`k3`, SendGrid `s1`/`s2`, HubSpot `hs1`/`hs2`, Klaviyo `dkim`, Mandrill `mandrill`, Amazon SES a long random selector.
- ❌ No record at the selector → the ESP's DKIM isn't published. Have the user copy the CNAME/TXT records from the ESP's sending-domain setup screen.
- ✅ A `v=DKIM1; k=rsa; p=...` record resolves and the ESP reports DKIM as verified.

**DMARC** — tells receivers what to do when SPF/DKIM fail, and enables alignment.
```
dig +short TXT _dmarc.example.com
```
- ❌ No `v=DMARC1` record → publish at least `v=DMARC1; p=none; rua=mailto:dmarc@example.com`. `p=none` is the minimum the bulk rules require; `rua` gives you the aggregate reports to see what's failing.
- ⚠️ `p=none` is fine for compliance but offers no spoofing protection — once reports look clean, move to `p=quarantine` then `p=reject`.
- **Alignment check (the part people miss):** for DMARC to *pass*, the `From:` domain must align with the SPF domain **or** the DKIM `d=` domain. A message can have valid SPF and valid DKIM and still fail DMARC if neither aligns with the visible `From:`. If the user sends from `example.com` but the ESP signs as `esp-mail.com` with no aligned DKIM, DMARC fails. Fix: set up a **custom/authenticated sending domain** in the ESP so DKIM signs as `example.com`.

### Step 2 — Bulk-sender requirements compliance

Decide the tier first: **does the sender send 5,000+ messages in a day to a single provider?** (Gmail counts Gmail addresses; Yahoo counts Yahoo, etc.) Then check against the right column.

| Requirement | All senders | Bulk (5,000+/day to one provider) |
|---|---|---|
| SPF **or** DKIM | ✅ required | — |
| SPF **and** DKIM | — | ✅ both required |
| DMARC published | not required | ✅ required, `p=none` minimum |
| DMARC alignment | — | ✅ `From:` aligns with SPF or DKIM |
| One-click unsubscribe | — | ✅ `List-Unsubscribe` + `List-Unsubscribe-Post` headers (RFC 8058), honor within 2 days |
| Spam rate (Postmaster) | < 0.3% (target < 0.1%) | < 0.3%, and **never reach** 0.3% |
| Valid PTR / reverse DNS on sending IP | ✅ | ✅ |
| RFC 5322 compliant, valid `Message-ID`, single From:/To:/Subject:/Date: | ✅ | ✅ |
| No misleading From/Subject, no fake `Re:`/`Fwd:` | ✅ | ✅ |

The rules are nearly identical across **Gmail, Yahoo, and Microsoft** (all adopted the 2024 bulk-sender standard). Differences worth naming: Yahoo states explicitly to **honor unsubscribes within 2 days** and recommends the RFC 8058 POST method; Microsoft's high-volume enforcement (10,000+/day) is rolling out on the same shape. See `references/provider-rules.md` for the side-by-side and source links.

**One-click unsubscribe — the exact headers (bulk marketing mail must have both):**
```
List-Unsubscribe: <https://example.com/unsubscribe?id=abc>, <mailto:unsub@example.com>
List-Unsubscribe-Post: List=Unsubscribe=One-Click
```
A visible unsubscribe link in the body is still required too. The header without `List-Unsubscribe-Post` is the old style and does **not** satisfy one-click. Most modern ESPs add these automatically — verify by viewing raw headers of a real send.

### Step 3 — Spam-rate interpretation

The spam rate in Postmaster Tools (complaints ÷ delivered) is the number that gets you blocked. Translate it for the user:

- **< 0.1%** — healthy. This is the *target*, not just the limit.
- **0.1%–0.3%** — caution zone. You're compliant but trending wrong; one bad campaign tips you over.
- **≥ 0.3%** — failing. Gmail/Yahoo say *never* reach this. At this level mail is actively being filtered and reputation is damaged; recovery takes weeks.

If they're over: the fix is almost never authentication — it's **list quality and consent**. Drivers: buying/scraping lists, no re-confirmation of old contacts, hard-to-find unsubscribe (so people hit "report spam" instead), sending to people who forgot they opted in, irrelevant content. Remediation order: stop sending to the coldest segment → make unsubscribe one tap → re-engagement campaign or sunset the unengaged → only then resume normal volume.

If they have **no Postmaster Tools** set up, that's a finding on its own: they're flying blind. Have them verify the domain at the Postmaster Tools link in references and wait for data to accumulate (needs meaningful volume).

### Step 4 — Warm-up & deferral playbook

New domains/IPs have no reputation. Sending full volume on day one looks exactly like a spammer and gets throttled or blocked. This is the step people skip and then can't understand why a perfectly-authenticated domain goes to spam.

**Ramp schedule (new sending domain or dedicated IP):**
- Start small — your most engaged contacts only (openers/clickers from the last 30–90 days). Engagement on early sends builds reputation fastest.
- Increase volume **25–100% per day**, not more.
- Keep volume **consistent within a day and across days** — same rough number at the same times. Spiky sending reads as suspicious. Consistency matters more than raw volume.
- Expect 2–6 weeks to reach full volume depending on list size.

**Deferral recovery (you're getting 421 / "deferred" responses):**
1. A 421 deferral means the receiver is rate-limiting you, not rejecting you. Don't panic-retry harder.
2. **Wait 15 minutes.** Then send **one** test message and confirm it's accepted.
3. Hold volume **below the threshold that triggered the deferral for the next 24 hours.**
4. After 24 clean hours, resume increasing by 25–100%/day.
5. If deferrals persist at low volume, the problem is reputation or content, not rate — go back to Step 3.

### Step 5 — Content & infrastructure red flags

Fast checks that sink deliverability regardless of auth:
- **Misleading headers** — deceptive `From:` display name, clickbait/mismatched `Subject:`, fake `Re:`/`Fwd:` prefixes. Disqualifying under the rules.
- **Emoji-stuffed or all-caps subjects** — filter bait.
- **Hidden content** — text hidden with HTML/CSS, white-on-white, tiny fonts. Treated as deceptive.
- **Shared IP / domain across unrelated senders** — you inherit their reputation. Bulk senders should not share.
- **Spoofing any domain you don't own** — never. DMARC exists to stop exactly this.
- **Image-only emails / bad text-to-image ratio** — looks like spam, also breaks for image-blocked readers.
- **Link domain mismatch** — links pointing to a domain unrelated to the sender erode trust.

## Output format

```
## Deliverability Audit — <domain>

**Sender tier:** <All senders | Bulk (5,000+/day to one provider)>
**Verdict:** <✅ Compliant & healthy | ⚠️ At risk | ❌ Failing>

### Authentication
- SPF:   <✅/⚠️/❌> <finding> → <exact fix / record to publish>
- DKIM:  <✅/⚠️/❌> <selector checked> <finding> → <fix>
- DMARC: <✅/⚠️/❌> <policy found> <alignment result> → <fix>

### Bulk-sender compliance  (only if bulk tier)
- One-click unsubscribe: <present? both headers?> → <fix>
- Spam rate: <number> → <healthy / caution / failing> 
- <any other failing requirement>

### Spam-rate read
<what their number means and the remediation order, if applicable>

### Warm-up / deferrals
<ramp status or deferral-recovery steps, if relevant>

### Prioritized fix list
1. <highest-impact fix — usually an auth or alignment failure>
2. <next>
3. <next>

### The one thing
<the single fix that matters most right now>
```

## Rules

1. **Authentication before everything.** A list-quality fix on a domain with failing DMARC is wasted — the mail won't be trusted no matter how good the list.
2. **Run the real lookups.** Don't assume records exist; `dig` them. "I think SPF is fine" is not a finding.
3. **Name the alignment trap.** Valid SPF + valid DKIM can still fail DMARC if neither aligns with `From:`. Check it every time.
4. **0.3% is the limit; 0.1% is the goal.** Don't tell a user they're "fine" at 0.25% — they're one campaign from trouble.
5. **Consent is not optional.** If the deliverability problem is "we email people who didn't ask," the fix is the list, not the DNS. Say so plainly. Do not help send mail recipients didn't opt into.
6. **Cite the source.** When you state a requirement, you can point the user to the official page (see references). The rules change; the links are authoritative.

## References

- `references/auth-records.md` — SPF/DKIM/DMARC record syntax, per-ESP DKIM selectors, the `dig` commands.
- `references/provider-rules.md` — Gmail vs Yahoo vs Microsoft side-by-side, with official source links.
