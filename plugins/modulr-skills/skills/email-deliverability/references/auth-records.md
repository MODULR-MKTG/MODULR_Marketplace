# Authentication Records — SPF, DKIM, DMARC

Reference for auditing and fixing the three email authentication records. All lookups use `dig` (macOS/Linux) — on Windows use `nslookup -type=TXT <name>`.

## SPF (Sender Policy Framework)

Declares which servers are allowed to send mail for the domain. Published as a single TXT record at the domain root.

**Look it up:**
```
dig +short TXT example.com | grep -i spf
```

**Anatomy:**
```
v=spf1 include:_spf.google.com include:sendgrid.net ~all
```
- `v=spf1` — version tag, must be first.
- `include:<domain>` — authorizes another domain's senders (this is how you add your ESP).
- `ip4:` / `ip6:` — authorize specific IPs.
- `~all` — softfail (recommended): mail from unlisted servers is marked, not rejected.
- `-all` — hardfail: strictly reject. Use once you're confident every legit sender is listed.
- `+all` — **never**; authorizes the entire internet.

**Common failures:**
- **No record** → publish one including your ESP. Get the exact `include:` from the ESP's docs.
- **Too many DNS lookups** → SPF allows a max of **10** nested DNS lookups; exceed it and SPF returns `permerror` (= fail). Each `include:` can chain more. Fix by removing unused includes or using an SPF-flattening service.
- **Multiple SPF records** → only one `v=spf1` TXT record is allowed; two = invalid. Merge them.
- **Ends in `+all`** → tighten to `~all` or `-all`.

**Common ESP includes:**
| ESP | SPF include |
|---|---|
| Google Workspace | `include:_spf.google.com` |
| Microsoft 365 | `include:spf.protection.outlook.com` |
| SendGrid | `include:sendgrid.net` |
| Mailchimp / Mandrill | `include:servers.mcsv.net` |
| HubSpot | `include:_spf.hubspotemail.net` |
| Klaviyo | `include:_spf.klaviyo.com` |
| Amazon SES | `include:amazonses.com` |
| ActiveCampaign | `include:emsd1.com` (varies by plan) |

## DKIM (DomainKeys Identified Mail)

Cryptographically signs each message; the public key lives in DNS at a **selector**. You must know the selector to look it up — the ESP chooses it.

**Look it up (replace `<selector>`):**
```
dig +short TXT <selector>._domainkey.example.com
```

**Anatomy of the published key:**
```
v=DKIM1; k=rsa; p=MIGfMA0GCSq... (long base64 public key)
```
- A valid record resolves and contains `p=` with a non-empty key.
- Empty `p=` (`p=`) means the key was revoked.

**Per-ESP DKIM selectors** (where to look when the user doesn't know):
| ESP | Selector(s) | Lookup name |
|---|---|---|
| Google Workspace | `google` | `google._domainkey.example.com` |
| Microsoft 365 | `selector1`, `selector2` | `selector1._domainkey.example.com` |
| Mailchimp | `k1`, `k2`, `k3` | `k1._domainkey.example.com` |
| Mandrill | `mandrill` | `mandrill._domainkey.example.com` |
| SendGrid | `s1`, `s2` | `s1._domainkey.example.com` |
| HubSpot | `hs1`, `hs2` (+ a hash prefix) | `hs1-XXXX._domainkey.example.com` |
| Klaviyo | `dkim` | `dkim._domainkey.example.com` |
| Amazon SES | random per-identity | shown in the SES console as 3 CNAMEs |
| ActiveCampaign | `dk` | `dk._domainkey.example.com` |

Many ESPs publish DKIM as **CNAME** records pointing back to the ESP (so they can rotate keys) rather than the TXT key directly — `dig` will show the CNAME and resolving it shows the key. Either is fine as long as it resolves and the ESP reports DKIM "verified."

**Common failures:**
- **No record at the selector** → the ESP's DKIM was never published. Copy the CNAME/TXT records from the ESP's "authenticate domain" / "sending domain" screen into DNS.
- **Wrong selector checked** → try the ESP's known selectors above; check the ESP dashboard for the exact one.
- **Key present but ESP says unverified** → DNS propagation (wait) or a typo in the published record.

## DMARC (Domain-based Message Authentication, Reporting & Conformance)

Tells receivers what to do when SPF/DKIM fail, and ties authentication to the visible `From:` via **alignment**. Published at `_dmarc.<domain>`.

**Look it up:**
```
dig +short TXT _dmarc.example.com
```

**Anatomy:**
```
v=DMARC1; p=none; rua=mailto:dmarc-reports@example.com; pct=100; adkim=r; aspf=r
```
- `p=` — policy: `none` (monitor only), `quarantine` (spam folder), `reject` (block). **Bulk-sender minimum is `p=none`.**
- `rua=mailto:` — where aggregate XML reports go. Always set this; it's how you see what's failing before tightening the policy.
- `pct=` — percent of mail the policy applies to (ramp tool; default 100).
- `adkim` / `aspf` — alignment mode, `r` relaxed (default, recommended) or `s` strict.

**Alignment — the trap to check every time:**
DMARC passes only if **at least one** of these holds:
- SPF passes **and** the SPF (envelope/return-path) domain aligns with the `From:` domain, **or**
- DKIM passes **and** the DKIM `d=` domain aligns with the `From:` domain.

A message can have valid SPF and valid DKIM and **still fail DMARC** if neither aligns with the visible `From:`. This is the #1 silent failure for senders using an ESP's shared domain. **Fix:** set up a custom/authenticated sending domain in the ESP so DKIM signs as your own domain (`d=example.com`), aligning with `From: you@example.com`.

**Policy progression (don't jump straight to reject):**
1. `p=none` + `rua` → collect reports, confirm all legit mail aligns.
2. `p=quarantine; pct=10` → ramp up `pct` as reports stay clean.
3. `p=reject` → full protection once you're certain nothing legit fails.

**Common failures:**
- **No record** → publish `v=DMARC1; p=none; rua=mailto:dmarc@example.com`.
- **`p=none` forever** → compliant but no spoofing protection. Once reports are clean, advance the policy.
- **Legit mail failing alignment** → almost always a missing aligned DKIM; authenticate the sending domain in the ESP.

## Supporting records

- **PTR / reverse DNS** — the sending IP should resolve back to a hostname (`dig -x <ip>`). Missing PTR hurts reputation; dedicated-IP senders must set this with their host.
- **MX** — not part of sending auth, but a domain with no MX that sends mail looks suspicious to some filters.
