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
