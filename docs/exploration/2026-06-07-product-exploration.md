# Kin — Product Exploration Working Notes

> **Purpose:** Durable memory for an ongoing product-direction exploration. This file
> captures the *facts* about the app's current state, the *directions* under
> consideration, the *open decisions*, and *where we left off* — so any future session
> (human or agent) can continue without re-investigating.
>
> **Companion doc:** `PRODUCT_BRIEF.md` (the polished outward-facing brief).
> This file is the messier, fuller working log behind it.

**Started:** 2026-06-07
**Status:** **Direction chosen (2026-06-08): A (Ritual) as spine, fed by B (recall) + C (capture). D/E deferred.** See §5 session 2 and `PRODUCT_BRIEF.md` Part II.

---

## 0. How to use this file

- Treat sections 1–2 as **established fact** (verified against code on 2026-06-07).
- Section 3 is the **decision space** — the five directions. Not yet narrowed.
- Section 4 is **open questions** that gate the decision.
- Section 5 is the **running log** — append to it each session with date-stamped entries.
- When a direction is chosen, record it in Section 5 and update `PRODUCT_BRIEF.md`.

---

## 1. Verified current state of the app (as of 2026-06-07)

Source: full codebase read + `bd stats`. The app is a **~80% feature-complete MVP**.

### Implemented & working end-to-end
- **Data model** (`lib/data/database/tables/`): `contacts`, `circles`, `contact_circles` (junction), `interactions`. All have UUID PKs, `created_at`/`updated_at`, `deleted_at` (soft delete), `is_dirty` (sync flag). **Genuinely sync-ready.**
  - `contacts`: name, avatar_local_path, phone, email, **birthday (exists but UNUSED)**, job_title, cadence_days (default 30), last_contacted_at, snoozed_until.
  - `interactions`: contact_id, type (call/meetup/message/email/gift), content (markdown), **is_preparation** (prep-before vs reflection-after), happened_at.
  - `circles`: name, color_hex.
- **Daily Deck** (`core/providers/daily_deck_providers.dart`, `presentation/screens/daily_deck_screen.dart`, `widgets/swipeable_deck_card.dart`):
  - Due logic (`contact_repository.dart:211-231`): due if NOT snoozed AND (`last_contacted_at` null OR `last_contacted_at + cadence_days ≤ today`) AND not deleted. Sorted most-overdue-first; never-contacted sorts first.
  - Health rings (`widgets/health_ring.dart:63-88`): `progress = elapsed / cadence`. Green <50%, Yellow 50–100%, Red >100%; never-contacted = full red.
  - Swipe right = quick-log (creates `message` interaction, sets last_contacted_at now, snackbar w/ undo). Swipe left = snooze (presets + custom date). Haptics on both.
  - Confetti + "good friend" empty state on deck clear.
- **Interactions**: editor with 5 type chips, prep/reflection toggle, date/time picker, markdown editor + mobile toolbar (B/I/•/H1).
- **Contacts**: full CRUD, avatar picker (saved to `<appDocs>/avatars/`), cadence presets (7/14/30/90).
- **Circles**: full CRUD + color, filtering in contact list.
- **Search**: debounced (300ms) across contacts/interactions/circles.
- **Timeline**: all interactions chronologically, filter by type.
- **Settings**: timeline link, manage circles, import, about.
- **Contact import**: iPhone import WORKS (dedup by phone/email/name, avatar store, circle assignment). Uses `fast_contacts`.

### Partial / stubbed
- **Import**: CSV/vCard = "Coming soon" placeholders (`import_source_screen.dart`). Selection UI + dedup tests still open (epic-10).
- **"Add Note" after quick-log**: snackbar action wired to empty handler (`swipeable_deck_card.dart:177`, ref kin-61v).
- **Birthday on import**: not captured — `fast_contacts` can't read contact events (we swapped off `flutter_contacts` due to iOS 26 SIGTRAP; see pubspec comment).

### NOT present at all (key gaps)
- **❗ Notifications / reminders / background scheduling — NONE.** No `flutter_local_notifications`, no `workmanager`. **This is the structural flaw:** a "gentle nudges / habit" app that cannot reach the user.
- No sync/backend (despite sync-ready schema).
- No AI/enrichment, no analytics/insights, no data export/backup, no dark mode toggle, no markdown *rendering* in most views (stored, shown ~plain), no call/SMS/calendar integration, no birthday alerts.

### Tracker state
- `bd`: 81 issues, 74 closed. Open: epic-10 (Contact Import) sub-tasks + "design app icon" (kin-fjr).
- Recent work (git log): epics 7–9 (Daily Deck, Search, Polish) done; epic-10 import in progress.

---

## 2. The intent (from SPEC.md / PRD v1.0)

Three promises:
1. **Memory Extension** — never forget what you discussed last time.
2. **Habit Formation** — move from *guilt* to *routine* with *gentle nudges*.
3. **Privacy** — complete data sovereignty (local-first).

Design soul: **Delight over Data** — feel like a journal/game, not a spreadsheet. Headline metric: **Time to Delight** (how fast you clear today's deck). Personal, *not* a business CRM. JTBD: *"Help me be a better friend/son/partner without the guilt of letting people drift."*

PRD's own post-MVP roadmap: backend sync (Go/Node, LWW), smart enrichment (avatar/bio by email), gift tracking, contact-relationship graph.

### The central tension (the through-line of this whole exploration)
The product promises *nudges* and *habit*, but **the app is purely passive — it cannot notify.** A relationship app you must *remember* to open recreates the exact out-of-sight/out-of-mind failure it's trying to cure. **Every direction below must reckon with this.**

---

## 3. The decision space — five directions for "better"

Not mutually exclusive; each is a different *center of gravity* / first-investment.

| # | Name | North star | "Better" = | Beachhead feature | Primary risk |
|---|------|-----------|-----------|-------------------|--------------|
| **A** | **The Ritual** | Daily habit loop | App reaches you; you return | Local notifications + clearable deck + forgiving streaks | Notification fatigue / re-introducing guilt |
| **B** | **The Second Brain** | Effortless recall | You arrive already remembering | Pre-contact "brief" card; render markdown; open follow-up loops | Only as good as what's captured |
| **C** | **Ambient Capture** | Zero-friction logging | The log fills itself | Share-sheet inbound; "did you reach them?" after nudge; voice/calendar | Platform limits (esp. iOS); privacy bar rises |
| **D** | **The Mirror** | Self-awareness | You see your social life clearly | Drift detection; circle balance; monthly "good friend" report | Tips into judgment/guilt |
| **E** | **The Vault** | Trust & longevity | Data you'd trust for decades | Export/backup; then E2E-encrypted multi-device sync | Low near-term wow; sync is a tar pit |

### How they relate (one engine, five emphases)
```
A (Ritual)  → gets you to open it
C (Capture) → gets data in effortlessly
B (Brain)   → makes that data pay off in the moment
D (Mirror)  → makes it pay off over time
E (Vault)   → makes it safe to keep doing forever
```

### ✅ Decision (2026-06-08): A spine, B + C feeding it
Ratified by product owner. **A (Ritual)** is the spine; **B (recall of last conversations)**
and **C (capture of new topics)** are what make the ritual worth doing, not separate later
phases. D/E deferred. The hinge is the existing `is_preparation` flag: reflection notes = B,
prep notes = C, the deck card = A. Full development in `PRODUCT_BRIEF.md` Part II
(core loop, per-strand contributions, 4-phase roadmap, success metrics).

### Prior recommendation (now ratified, kept for history)
Lead **A → C → B**, layer D and E later.
- **A first:** spec-mandated, ~80% built, fixes the fatal flaw with least effort.
- **C next:** A creates the occasion to log; C removes the friction.
- **B then:** the premium payoff / monetization basis.
- One-sentence "better": *Stop being a journal you must remember to write in; become a quiet companion that reaches out at the right moment, makes logging nearly free, and hands you the memory you need exactly when you need it.*

---

## 4. Open questions (these gate the decision — answer before committing)

1. **Target user?** Mass-market "good friend" (tips toward A/C) vs. high-touch networker with 200+ contacts (tips toward B). — *unanswered*
2. **Monetization?** None / premium "Second Brain" (B) / privacy "Vault" (E)? — *unanswered*
3. **Nudge aggressiveness?** How far before "gentle" becomes the guilt we promised to remove? — *unanswered*
4. **Platform priority?** iOS-first (constrains C's call-log ambitions) vs. Android parity? — *unanswered*
5. **Solo passion project vs. product to ship/grow?** Changes how much E (sync infra) is worth. — *unanswered*

---

## 5. Running log (append each session)

### 2026-06-07 — Session 1 (exploration kickoff)
- Read SPEC.md, full `lib/` tree, ran `bd stats`/`bd list`. Confirmed ~80% MVP, no notifications anywhere.
- Wrote `PRODUCT_BRIEF.md` (polished brief) + this working-notes file.
- Proposed 5 directions (A–E above). Recommended A→C→B. **No direction chosen yet. Nothing committed to git.**
- **Next-step options (pick up here):**
  1. Answer the Section-4 open questions (fastest way to narrow A–E).
  2. If A is chosen → spike `flutter_local_notifications`: daily deck reminder + birthday alerts (birthday field already exists, unused).
  3. File directions as beads epics (`bd create`) once one or two are chosen.
  4. Decide whether to commit/push `PRODUCT_BRIEF.md` + this file (CLAUDE.md mandates push at session end — currently NOT done, by request, pending review).

### 2026-06-08 — Session 2 (direction chosen)
- **Product owner chose Direction A** as the spine, with **B and C feeding it** — the ritual
  should surface *last conversations* (B) and *new topics you've been meaning to raise* (C).
- Key framing locked: A/B/C are **one loop**, not three features. Hinge = existing
  `is_preparation` flag (reflection = B recall, prep = C capture, deck card = A ritual).
- Extended `PRODUCT_BRIEF.md` with **Part II**: core-loop diagram, per-strand contributions,
  4-phase roadmap (A core → B recall → C capture → A reinforce), success metrics, updated Qs.
- Resolved open Q3 (nudge philosophy): gentle = forgiving/opt-in/positive; opt-out rate is the guardrail.
- Still open: target user (mass vs networker), monetization, platform priority, notification cadence default.
- **Next-step options (pick up here):**
  1. File Direction-A work as beads epics/issues — Phase 1 first (`flutter_local_notifications` foundation, birthday alerts, deck cap).
  2. Answer remaining open questions (target user / monetization / platform) to finalize Phase 3 scope.
  3. Begin Phase 1 implementation (TDD per CLAUDE.md) once issues are filed.

---

## 6. Implied near-term backlog (from the A→C→B recommendation)

Not yet filed as beads issues. Rough priority:
- [ ] **Local notifications foundation** — `flutter_local_notifications`; daily deck reminder, configurable time. *(unblocks all of A)*
- [ ] **Birthday alerts** — use existing unused `birthday` field.
- [ ] **Forgiving streaks + weekly recap** — habit reinforcement w/o guilt.
- [ ] **Deck daily-cap setting** — keep Time-to-Delight low; always clearable.
- [ ] **Share-sheet inbound capture** — log from any app. *(C beachhead)*
- [ ] **"Did you reach them?" return prompt** after Nudge → auto-log. *(closes existing outbound loop)*
- [ ] **Pre-contact brief card** — last interaction + open prep notes + days-since. *(B beachhead)*
- [ ] **Render stored markdown** in detail/timeline views.
- [ ] **Data export / backup** — proof of local-first promise. *(E beachhead)*
- [ ] Finish epic-10 import (selection UI, dedup tests, birthday restore).
