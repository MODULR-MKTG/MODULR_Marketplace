# Provider Sender Rules — Gmail vs Yahoo vs Microsoft

The big three mailbox providers adopted a shared bulk-sender standard in 2024. The requirements are nearly identical; the differences are small but worth naming. Always confirm against the official pages (linked below) — these rules get updated.

## Who counts as a "bulk sender"

- **Gmail / Yahoo:** 5,000+ messages to that provider's addresses in a **single day**. Cross that line once and you're treated as a bulk sender going forward.
- **Microsoft (Outlook.com / Hotmail):** high-volume enforcement targets senders at **10,000+/day**, rolling out on the same authentication shape.

Count per provider: 5,000 Gmail addresses in a day makes you a Gmail bulk sender, independent of your Yahoo volume.

## Side-by-side

| Requirement | Gmail | Yahoo | Microsoft |
|---|---|---|---|
| SPF or DKIM (all senders) | ✅ | ✅ | ✅ |
| SPF **and** DKIM (bulk) | ✅ | ✅ | ✅ |
| DMARC published (bulk) | ✅ `p=none` min | ✅ `p=none` min, must pass | ✅ `p=none` min |
| DMARC alignment with `From:` | ✅ | ✅ (SPF or DKIM, relaxed OK) | ✅ |
| One-click unsubscribe (bulk marketing) | ✅ List-Unsubscribe + Post | ✅ + honor within 2 days | ✅ |
| Visible unsubscribe link in body | ✅ | ✅ | ✅ |
| Spam rate < 0.3% (target < 0.1%) | ✅ never reach 0.3% | ✅ keep below 0.3% | ✅ keep complaints low |
| Valid PTR / reverse DNS | ✅ | ✅ | ✅ |
| RFC 5322 compliant + valid Message-ID | ✅ | ✅ | ✅ |
| No misleading From/Subject, no fake Re:/Fwd: | ✅ | ✅ | ✅ |

## Notable per-provider specifics

**Gmail**
- Spam rate is measured in **Postmaster Tools** — set it up; it's the authoritative number.
- Guidance: keep the rate below 0.3% and **avoid ever reaching 0.30%**; aim for under 0.1%.
- Increase sending volume gradually; maintain consistent volumes.

**Yahoo**
- Explicitly requires honoring **unsubscribe requests within 2 days**.
- Recommends the RFC 8058 one-click **POST** method, not just the mailto form.
- DMARC must **pass** (relaxed alignment is acceptable); `From:` must align with SPF or DKIM.

**Microsoft**
- High-volume sender enforcement (10,000+/day) requires SPF + DKIM + DMARC, on the same model.
- Smart Network Data Services (SNDS) and the JMRP (Junk Mail Reporting Program) are Microsoft's reputation/feedback tools — the analog to Postmaster Tools.

## Monitoring tools (set these up)

- **Google Postmaster Tools** — spam rate, auth rates, reputation, delivery errors. Requires meaningful volume to populate. https://postmaster.google.com/
- **Yahoo Sender Hub / Complaint Feedback Loop (CFL)** — https://senders.yahooinc.com/
- **Microsoft SNDS + JMRP** — https://sendersupport.olc.protection.outlook.com/

## Official source pages

- Gmail — Email sender guidelines: https://support.google.com/mail/answer/81126
- Gmail — Fix messages going to spam / sender troubleshooting: https://support.google.com/mail/answer/15256272
- Yahoo — Sender best practices: https://senders.yahooinc.com/best-practices/
- Microsoft — High-volume sender requirements: https://learn.microsoft.com/ (search "Outlook high-volume sender requirements")
- RFC 8058 — One-Click List-Unsubscribe: https://www.rfc-editor.org/rfc/rfc8058
- RFC 5322 — Internet Message Format: https://www.rfc-editor.org/rfc/rfc5322

*Requirements current as of the 2024 bulk-sender standard. Verify against the official pages above before relying on a specific threshold — providers update these.*
