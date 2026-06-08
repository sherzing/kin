# Kin — Product Brief & Strategic Directions

**Date:** 2026-06-07
**Author:** Product analysis (Claude)
**Status:** For discussion
**Inputs:** `SPEC.md` (PRD v1.0), current codebase (~80% MVP-complete), beads tracker (74/81 issues closed)

---

## 1. The intent, restated

The original PRD frames Kin around three promises:

1. **Memory Extension** — "Never forget what you discussed last time."
2. **Habit Formation** — "Move from *guilt* to *routine* with gentle nudges."
3. **Privacy** — "Complete data sovereignty (local-first)."

And one design soul: **Delight over Data.** It should feel like a journal or a game, not a spreadsheet. The headline metric is *Time to Delight* — how fast you can clear today's deck.

The product is a **personal** relationship manager, deliberately *not* a business CRM. The emotional job-to-be-done is: *"Help me be a better friend / son / partner without the nagging feeling that I'm letting people drift away."*

## 2. Where the product actually is today

The build is impressively complete for an MVP. What exists and works end-to-end:

- **Data model** — contacts, circles (tags), interactions, junction table. UUID PKs, soft-deletes, `is_dirty` flags. Genuinely sync-ready as promised.
- **Daily Deck** — due logic (`last_contacted + cadence ≤ today` AND not snoozed), health rings (green <50% / yellow 50–100% / red >100% of cadence elapsed), swipe-right quick-log, swipe-left snooze, confetti on clear, haptics. The spec's centerpiece is real.
- **Interactions** — 5 types, prep/reflection toggle, markdown editor with mobile toolbar, date/time picker.
- **Contacts** — full CRUD, avatar picker, cadence presets, circle assignment.
- **Circles, Search, Timeline, Settings** — all implemented.
- **Contact import** — iPhone import works (dedup, avatar store); CSV/vCard stubbed.

**The one structural gap that matters most:** there are **no notifications, no reminders, no background scheduling** anywhere in the app (`pubspec.yaml` has no notification/workmanager dependency). The deck only updates when the user *chooses* to open the app.

### This is the central tension

Kin's stated purpose is *"habit formation with gentle nudges"* — but **the app cannot nudge.** It is a beautifully built passive surface that waits to be visited. A relationship app you have to *remember* to open has the same failure mode as the relationships it's trying to save: out of sight, out of mind. **Whatever direction we pick, this gap is the gravity well.**

Everything below proposes a *direction for what "better" means* — they are not mutually exclusive, but each implies a different center of gravity, a different first hire of engineering effort, and a different definition of success.

---

## 3. Five directions for "better"

| # | Direction | North star | "Better" means… | Primary risk |
|---|-----------|-----------|-----------------|--------------|
| A | **The Ritual** | Daily habit loop | The app reaches you, you come back | Notification fatigue |
| B | **The Second Brain** | Effortless recall | You walk in already knowing | Manual-entry burden |
| C | **Ambient Capture** | Zero-friction logging | The log fills itself | Platform/privacy limits |
| D | **The Mirror** | Self-awareness | You see your social life clearly | Can feel judgmental |
| E | **The Vault** | Trust & longevity | Data you'd trust for decades | Low near-term wow |

### Direction A — "The Ritual" — make Kin a habit you can't drop

**Thesis:** The PRD already chose this ("guilt → routine, gentle nudges"); the build just hasn't honored it. Close the loop. The deck becomes a *daily ritual* like Duolingo's lesson or Headspace's session — a small, finishable, satisfying thing that the app actively invites you to.

**What "better" looks like:**
- **Local notifications** (the missing keystone): a single daily "Your deck is ready — 3 people today" nudge, time-of-day configurable. Birthday-morning alerts (the `birthday` field already exists and is unused).
- **Streaks & gentle stakes** — "12-day streak of staying connected." Forgiving by design (the PRD says *guilt → routine*, so streaks must never shame — a missed day is "welcome back," not a broken chain reset to zero).
- **Right-sized daily load** — cap the deck (e.g. "today's 5"), so it's always *clearable*. Time-to-Delight becomes the optimized metric.
- **Snooze that feels kind**, weekly "you reconnected with 8 people" recap.

**Who it's for:** People who *want* to be better friends but lose the thread. The mass-market emotional buyer.

**Why it's compelling:** It's the lowest-effort, highest-leverage path *because the spec already pointed here and the code is 80% ready* — the deck, snooze, cadence, and haptics all exist. Notifications are the one missing organ. This is the direction I'd **recommend leading with**, regardless of which others follow.

**Risk:** Nudges that feel like nagging recreate the exact guilt the product promised to remove. The craft is in restraint — one good nudge beats five.

---

### Direction B — "The Second Brain" — win on *recall*, not reminding

**Thesis:** Lean into promise #1. The deepest value of a personal CRM isn't *who* to contact — it's walking into the conversation *already remembering* their kid's name, the job interview they were nervous about, the book you promised to send. Reminding is a commodity (your calendar can do it); *memory* is the moat.

**What "better" looks like:**
- **Pre-contact "brief" card** — when a contact surfaces, auto-assemble a glanceable digest: last interaction, open prep notes, "last time you discussed…", upcoming birthday, days since contact. The prep/reflection split already in the schema is the seed of this.
- **Render the markdown** (currently stored but shown largely as plain text), with structured highlights — pull `@mentions`, dates, and "to-do for next time" lines out of notes.
- **Threaded memory** — "things I want to follow up on" as first-class open loops that resurface, not just free text.
- **(Roadmap tie-in)** Smart Enrichment — optional avatar/bio fetch by email; AI-summarize a long history into "what you know about this person."

**Who it's for:** High-touch networkers, people with large or emotionally complex circles, the "I have 200 people I genuinely care about and can't hold it all" user.

**Why it's compelling:** It's the most *defensible* and most premium-feeling. It turns logged data into a compounding asset — the longer you use Kin, the more irreplaceable it becomes. Strong fit for a paid tier.

**Risk:** Recall is only as good as what's captured, and capture is manual today — which is exactly why Direction C exists.

---

### Direction C — "Ambient Capture" — make logging disappear

**Thesis:** Every personal CRM dies the same death: people stop logging. The PRD's own UX principle is "logging in <3 taps" — go further: aim for *zero*. The best log is one the user didn't have to write.

**What "better" looks like:**
- **Share-sheet capture** — share a text/photo/voice memo *into* Kin from any app; it attaches to the right contact as an interaction. (`url_launcher` exists for outbound nudges; this is the inbound twin.)
- **Calendar awareness** — a meeting with a known contact prompts a one-tap "log this?" afterward.
- **Voice reflection** — hold-to-talk after a call → transcribed reflection note.
- **Nudge → log handoff** — the spec's "Nudge opens WhatsApp/iMessage" already fires an *outbound* action; close the loop by asking "did you reach them?" on return, auto-logging the touch.
- **Call-log assist** (Android-permitting) — surface recent calls to known contacts as quick-log suggestions.

**Who it's for:** Busy people who'd benefit from Kin but will never sit down to journal. The pragmatic majority who abandon journaling apps.

**Why it's compelling:** It directly attacks the #1 churn cause for this entire category. It's the force-multiplier that makes A *and* B actually work — a habit (A) and a memory (B) are both worthless if the data never gets in.

**Risk:** Platform constraints (iOS is strict on call logs; `fast_contacts` already cost us birthday access). Ambient capture also raises the privacy bar — which loops to Direction E.

---

### Direction D — "The Mirror" — turn data into self-awareness

**Thesis:** Give the user a calm, honest picture of their relational life. Not a dashboard of vanity metrics — a *mirror*. "Who's quietly drifting? Which circle have I neglected this season? Am I only ever reactive?"

**What "better" looks like:**
- **Drift detection** — surface people sliding from green→red *before* they're overdue, especially historically-close contacts gone quiet.
- **Circle balance** — "You've seen #work 14× and #family 2× this month." Gentle, not scored.
- **Seasonal rhythm** — interaction frequency over time; spot your own busy/quiet patterns.
- **The "good friend" report** — the empty-state already says *"Relax, you're a good friend!"*; make that a real, earned, monthly reflection.

**Who it's for:** Reflective, intentional users; the "examined life" segment; people using Kin as a personal-growth tool.

**Why it's compelling:** It's a distinctive *emotional* angle no business CRM would ever take, and it deepens the "delight, not spreadsheet" identity. Great for retention via periodic insight moments.

**Risk:** Tips into guilt/judgment fast — the precise emotion the product swore to remove. Must be framed as encouragement, opt-in, and never a leaderboard-of-shame.

---

### Direction E — "The Vault" — make local-first a real promise, not a footnote

**Thesis:** The schema is already sync-ready (UUIDs, dirty flags, soft-deletes) but nothing is delivered. Turn "local-first / data sovereignty" from an architecture note into a *product* — the relationship app you'd actually trust with your most intimate notes, and that will still be readable in 20 years.

**What "better" looks like:**
- **Backup & restore / export** — encrypted export, "your data is yours" in practice (no export exists today; a real gap for a sovereignty pitch).
- **E2E-encrypted multi-device sync** (the roadmap's Go/Node + LWW plan) — privacy-preserving, not just "in the cloud."
- **Trust surface** — visible "everything stays on your device" assurances, no-account onboarding, plain-text/markdown portability so users are never locked in.

**Who it's for:** Privacy-conscious users, the anti-Big-Tech segment, people burned by shut-down apps. A genuine differentiator vs. cloud CRMs like Clay/Monica-hosted.

**Why it's compelling:** It's a *positioning* moat more than a feature — and it unblocks multi-device, the most-requested practical ask once people commit real data. It also de-risks Directions B and C (more sensitive data → higher trust bar).

**Risk:** Lowest immediate "wow," highest infra cost. Sync/crypto is a tar pit; easy to over-invest before the habit (A) even exists to create data worth syncing.

---

## 4. Recommendation — how the directions relate

These aren't five roads; they're one engine with five emphases. My suggested reading:

```
        A (Ritual)  ──gets you to open it
            │
            ▼
        C (Capture) ──gets data in effortlessly
            │
            ▼
        B (Brain)   ──makes that data pay off in the moment
            │
            ▼
        D (Mirror)  ──makes it pay off over time
            │
        E (Vault)   ──makes it safe to keep doing forever
```

**Sequence I'd argue for:**

1. **Lead with A (Ritual).** It's spec-mandated, ~80% built, and fixes the fatal flaw: the app can't currently reach the user. Local notifications + a clearable daily deck + forgiving streaks. *Smallest effort, largest survival impact.*
2. **Then C (Ambient Capture)**, because A creates the *occasion* to log and C removes the *friction* of logging. Together they form the retention loop.
3. **Then B (Second Brain)** as the premium payoff and the basis for monetization.
4. **D and E are emphases to layer in** — D for periodic delight/retention, E when real data volume makes trust and multi-device the gating concern.

**If forced to pick one sentence for what "better" means:** *Kin should stop being a journal you must remember to write in, and become a quiet companion that reaches out at the right moment, makes logging nearly free, and hands you the memory you need exactly when you need it.* That's A → C → B.

---

## 5. Concrete near-term backlog implied by the recommendation

A starting set (would become beads issues), in rough priority:

- [ ] **Local notifications foundation** — add `flutter_local_notifications`, daily deck reminder, configurable time. *(unblocks all of Direction A)*
- [ ] **Birthday alerts** — use the existing, currently-unused `birthday` field.
- [ ] **Forgiving streaks + weekly recap** — habit reinforcement without guilt.
- [ ] **Deck daily-cap setting** — keep Time-to-Delight low; always clearable.
- [ ] **Share-sheet inbound capture** — log from any app. *(Direction C beachhead)*
- [ ] **"Did you reach them?" return prompt** after Nudge → auto-log. *(closes existing outbound loop)*
- [ ] **Pre-contact brief card** — assemble last interaction + open prep notes + days-since. *(Direction B beachhead)*
- [ ] **Render stored markdown** in detail/timeline views (currently mostly plain text).
- [ ] **Data export / backup** — concrete proof of the local-first promise. *(Direction E beachhead)*
- [ ] Finish open epic-10 import work (selection UI, dedup tests, birthday restore).

---

*Open questions for the product owner: (1) Is the target user the mass-market "good friend" or the high-touch networker? That choice tips the weight between A/C and B. (2) Is monetization expected, and if so is it the premium "Second Brain" (B) or the privacy "Vault" (E)? (3) How aggressive may nudges be before they feel like the guilt we're trying to remove?*

---

# Part II — Chosen direction: **The Ritual, fed by Memory and Capture**

> **Decision (2026-06-08):** Build **A (The Ritual)** as the product's spine.
> **B (Second Brain)** and **C (Ambient Capture)** are not separate later phases — they
> are the two things that make the daily ritual *worth doing*. The ritual captures
> **last conversations** (recall) and surfaces **new topics you've been meaning to raise**
> (capture). D (Mirror) and E (Vault) remain deferred.

## 6. The core idea: the ritual is a loop, and the loop already has a hinge

The mistake would be to treat A, B, and C as three features bolted together. They're one loop — and the data model *already contains its hinge*: the `is_preparation` flag on interactions.

- **Reflection** notes (`is_preparation = false`) = *what we last talked about* → this is **B (recall)**.
- **Prep** notes (`is_preparation = true`) = *what I want to bring up next time* → this is **C (capture)**.
- The **deck card** is where these two meet at the right moment → this is **A (the ritual)**.

So the product isn't "a deck, plus reminders, plus notes." It's a single habit loop:

```
        ┌─────────────────────────────────────────────────────┐
        │                                                       │
        ▼                                                       │
  (A) NUDGE ──────► OPEN DECK ──────► CONTACT CARD = a BRIEF    │
  "3 people today"   today's few      ┌─────────────────────┐  │
                                      │ • last time we spoke │  │  (B) recall
                                      │   about <X>          │  │
                                      │ • you wanted to ask  │  │  (C) surfaced
                                      │   about <Y>          │  │
                                      │ • 18 days since      │  │
                                      └─────────────────────┘  │
                                              │                 │
                              REACH OUT (nudge → WhatsApp/call)  │
                                              │                 │
                                       "did you reach them?"     │  (C) auto-log
                                              │                 │
                                    REFLECT (what we discussed)  │  (B) next time's recall
                                              │                 │
                                              └─────────────────┘
                                                                │
  ...and between rituals, a thought pops up:                    │
  "oh, I should ask Dad about his knee" ──► SHARE-SHEET / QUICK ADD ──► becomes a PREP note
                                                                         waiting on his next card
```

Every loop makes the next loop richer. The first time you open someone's card it's thin; after a few cycles it's a living memory of the relationship. **That compounding is the product.**

## 7. What each strand contributes (and why it's here, not later)

### A — The Ritual (the spine)
The job: make the app *reach out*, and make the daily task small and finishable.
- **Local notifications** — the missing keystone. One daily nudge ("Your deck is ready — 3 people today"), time-of-day configurable, plus birthday-morning alerts (the `birthday` field exists and is currently unused).
- **A clearable deck** — cap the daily load (e.g. "today's 5") so *Time to Delight* stays low and the deck is always finishable. Confetti/empty-state already reward the clear.
- **Forgiving streaks** — "12 days of staying connected," but a missed day is "welcome back," never a reset-to-zero shame mechanic. (This is our answer to open question #3: **gentle means forgiving, opt-in, and never guilt-inducing.** A nudge that makes you feel bad is a bug.)
- **Weekly recap** — "You reconnected with 8 people this week" — a positive reinforcement beat.

### B — Memory feeding the ritual (recall at the moment of contact)
The job: when a card surfaces, you should *already know what matters* before you reach out.
- **The brief card** — the deck card (and contact detail) lead with: last interaction + its topic, days since contact, upcoming birthday. This is **B's beachhead** and the single highest-value addition after notifications.
- **Open topics** — unresolved prep notes ("things I wanted to bring up") shown front-and-centre on the card, so the ritual *uses* what C captured.
- **Render the markdown** — notes are stored as markdown but shown largely as plain text today; render them so the recall is actually readable.

### C — Capture feeding the ritual (new topics, with near-zero friction)
The job: a thought about someone should reach their card without making you "do data entry."
- **Quick "add a topic"** — from a contact (and from the deck card), jot "ask about her new job" → stored as a prep note that resurfaces on the next ritual. This is the everyday capture path.
- **Share-sheet inbound** — share a text/photo/link from any app into Kin, attach to a contact as prep or reflection. The thought lands where it belongs without leaving the app you're in.
- **"Did you reach them?" return prompt** — the nudge already opens WhatsApp/iMessage (outbound); on return, ask once and auto-log the touch. Closes the loop the spec opened but never finished.
- **Wire the existing "Add Note" after quick-log** (`swipeable_deck_card.dart:177`, kin-61v) — today the snackbar action is a dead end; make swipe-right-then-elaborate a real capture path.

## 8. Phased roadmap

Each phase is shippable and leaves the app better than before. The ordering follows the loop: first make it *reach* you (A), then make the moment *worth it* (B), then make feeding it *frictionless* (C), then *reinforce* the habit (A again).

**Phase 1 — Make it reach you (A core).** *The fatal-flaw fix.*
- `flutter_local_notifications` foundation; daily deck reminder at a configurable time.
- Birthday-morning alerts (uses existing `birthday` field).
- Deck daily-cap setting.
- *Done = the app can run a daily habit without the user remembering to open it.*

**Phase 2 — Make the moment worth it (B).** *Recall at point of contact.*
- Brief card: last interaction + topic + days-since + birthday, on deck card and detail.
- Surface open/unresolved prep notes on the card.
- Render stored markdown in detail/timeline views.
- *Done = opening a card tells you what to say before you reach out.*

**Phase 3 — Make feeding it frictionless (C).** *Zero-friction capture.*
- Quick "add a topic" (prep note) from contact + deck card.
- Wire "Add Note" after quick-log (kin-61v).
- "Did you reach them?" return prompt after a nudge → auto-log.
- Share-sheet inbound capture.
- *Done = a passing thought about someone reliably ends up on their next card.*

**Phase 4 — Reinforce the habit (A polish).** *Stickiness.*
- Forgiving streaks; weekly "you reconnected with N people" recap.
- Snooze/nudge tone pass for warmth.
- *Done = the ritual feels rewarding, never nagging.*

**Later (unchanged):** D (Mirror — drift detection, circle balance, monthly report) and E (Vault — export/backup, then E2E sync). Pulled forward only if the open questions below push us there.

## 9. Success metrics (how we know "better" happened)

- **D1/D7/D30 ritual retention** — % of days a notified user opens the deck. *The* number for a habit product.
- **Deck clear rate** — % of surfaced decks fully cleared. Proxy for "right-sized and worth doing."
- **Time to Delight** — median seconds from open to deck-clear (PRD's own metric).
- **Capture rate** — prep notes created *between* rituals (the C loop working).
- **Brief richness** — % of surfaced cards that show ≥1 prior interaction or open topic (the B compounding working).
- **Nudge health (guardrail)** — notification opt-out / disable rate. If this climbs, "gentle" has become "nagging" — back off.

## 10. Open questions — updated

- **Resolved by this decision:**
  - *Direction:* A spine, B + C feeding it; D/E deferred.
  - *Nudge philosophy (was Q3):* gentle = forgiving, opt-in, positively framed; the opt-out rate is the guardrail.
- **Still open:**
  1. **Target user** — mass-market "good friend" vs. high-touch networker. Current plan suits the mass-market case; a networker focus would deepen B sooner and raise the deck cap.
  2. **Monetization** — none vs. premium "Second Brain" (B) vs. "Vault" (E). Affects how far B/E get pushed.
  3. **Platform priority** — iOS-first constrains some C capture paths (call-log); confirm before scoping Phase 3.
  4. **Notification cadence default** — one fixed daily time, or adaptive to when the user usually engages? (Start simple: one configurable time.)
