# Product Requirement Document (PRD): "Kin" Personal Relationship Manager

**Version:** 1.0  
**Date:** January 12, 2026  
**Status:** Draft  
**Target Platform:** Mobile (iOS/Android)  
**Tech Stack:** Flutter, SQLite (Drift), Riverpod

---

## 1. Executive Summary
**Kin** is a local-first mobile application designed to help users build the habit of maintaining personal relationships. Unlike business CRMs, Kin focuses on emotional connection, privacy, and user delight. It acts as a "second brain" for social interactions, allowing users to prepare for conversations and reflect on them afterwards.

### Core Value Proposition
* **Memory Extension:** Never forget what you discussed last time.
* **Habit Formation:** Move from "guilt" to "routine" with gentle nudges.
* **Privacy:** Complete data sovereignty (Local-first).

---

## 2. User Experience (UX) Principles
1.  **Low Friction:** The app must load instantly. Logging an interaction must take fewer than 3 taps.
2.  **Delight over Data:** The UI should feel like a journal or a game, not a spreadsheet.
    * *Key Metric:* "Time to Delight" – How fast can a user clear their daily tasks?
3.  **Sync-Ready Architecture:** While V1 is local-only, the data structure must support future cloud synchronization without refactoring.

---

## 3. Feature Specifications

### 3.1 The "Daily Deck" (Home Screen)
Instead of a static list, the home screen presents a prioritized "Deck" of people to contact today.

* **Logic:** Display contacts where `(Last Contacted Date + Cadence) <= Today` AND (`snoozed_until` is NULL OR `snoozed_until <= Today`).
* **Visual Interface:**
    * Card-based layout (Swipeable or vertically scrollable).
    * **Health Rings:** Avatar surrounded by a color-coded ring indicating relationship status (percentage-based thresholds).
        * 🟢 **Light Green (Mint):** 0-50% of cadence elapsed since last contact.
        * 🟡 **Light Yellow (Cream):** 50-100% of cadence elapsed (approaching due date).
        * 🔴 **Light Red (Rose):** Over 100% of cadence elapsed (overdue).
* **Card Actions:**
    * **Nudge:** Opens system share sheet (WhatsApp, iMessage, Email).
    * **Log:** Opens the Interaction Editor to record a conversation.
    * **Snooze:** Pushes the reminder back by X days (customizable). Stores `snoozed_until` timestamp; contact hidden from Daily Deck until this date passes.

### 3.2 Contact Management ("The Circle")
* **Onboarding/Import:**
    * Permission-based import from Device Contacts.
    * Deduplication check (merge by Phone/Email).
* **Profile Data:**
    * **Basic:** Name, Avatar (Local path), Phone, Email, Birthday, Job Title.
    * **Cadence:** Configurable integer (e.g., 7, 14, 30, 90 days).
    * **Circles (Tags):** Multi-select system (e.g., `#family`, `#college`, `#motorcycles`).

### 3.3 Interaction Logging (The Core Habit)
The editor supports two distinct mental modes:
* **Preparation Mode:** Notes created *before* an interaction (e.g., "Ask about their new job", "Remember to mention the book recommendation"). Flagged with `is_preparation = true`.
* **Reflection Mode:** Notes created *after* an interaction to capture what was discussed. This is the default mode (`is_preparation = false`).

* **Data Fields:**
    * `Type`: Call, Meetup, Message, Email, Gift.
    * `Date`: DateTime picker (Defaults to `Now`).
    * `Content`: Rich text field.
    * `Is Preparation`: Toggle to mark as a prep note vs. reflection.
* **Markdown Support:**
    * The Note field supports standard Markdown (Bold, Italic, Lists, Headers).
    * **Mobile Toolbar:** A custom row above the keyboard containing shortcuts (`B`, `I`, `•`, `H1`) to avoid typing raw Markdown syntax.

### 3.4 Search & Archives
* **Global Search:** Query against Name, Notes content, and Tags.
* **Timeline View:** A linear history of all interactions sorted by `happened_at` desc.

---

## 4. Technical Architecture

### 4.1 Technology Stack
| Layer | Technology | Rationale |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart) | Cross-platform, high-performance rendering. |
| **Database** | SQLite via `drift` | Type-safe SQL, supports migrations, highly performant. |
| **State Mgmt** | `flutter_riverpod` | compile-safe dependency injection, testable. |
| **Navigation** | `go_router` | Deep linking support, declarative routing. |
| **Formatting** | `flutter_markdown` | Rendering rich text notes. |
| **ID Generation** | `uuid` | Required for distributed system (future sync). |

### 4.2 Local Persistence Strategy
To allow future syncing to a backend, **Auto-Increment Integers are strictly forbidden** for Primary Keys.

* **Primary Keys:** UUID v4 Strings.
* **Soft Deletes:** Rows are never deleted. A `deleted_at` timestamp is set.
* **Dirty Flags:** An `is_dirty` boolean marks rows that have changed locally since the last sync.

### 4.3 Database Schema (Drift/SQL)

```sql
-- TABLE: contacts
CREATE TABLE contacts (
    id TEXT PRIMARY KEY NOT NULL, -- UUID
    name TEXT NOT NULL,
    avatar_local_path TEXT,
    phone TEXT,
    email TEXT,
    birthday INT, -- Unix Timestamp
    job_title TEXT,
    cadence_days INTEGER DEFAULT 30,
    last_contacted_at INT, -- Unix Timestamp (Calculated or stored)
    snoozed_until INT, -- Unix Timestamp, hides from Daily Deck until this date
    created_at INT NOT NULL,
    updated_at INT NOT NULL,
    deleted_at INT,
    is_dirty BOOLEAN DEFAULT 0
);

-- TABLE: circles (Tags)
CREATE TABLE circles (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    color_hex TEXT,
    created_at INT NOT NULL,
    updated_at INT NOT NULL,
    deleted_at INT,
    is_dirty BOOLEAN DEFAULT 0
);

-- TABLE: contact_circles (Junction Table)
CREATE TABLE contact_circles (
    contact_id TEXT NOT NULL,
    circle_id TEXT NOT NULL,
    created_at INT NOT NULL,
    updated_at INT NOT NULL,
    deleted_at INT,
    is_dirty BOOLEAN DEFAULT 0,
    PRIMARY KEY (contact_id, circle_id),
    FOREIGN KEY(contact_id) REFERENCES contacts(id),
    FOREIGN KEY(circle_id) REFERENCES circles(id)
);

-- TABLE: interactions
CREATE TABLE interactions (
    id TEXT PRIMARY KEY NOT NULL,
    contact_id TEXT NOT NULL,
    type TEXT NOT NULL, -- 'call', 'meetup', 'message', 'email', 'gift'
    content TEXT, -- Markdown content
    is_preparation BOOLEAN DEFAULT 0, -- 1 = prep note (before), 0 = reflection (after)
    happened_at INT NOT NULL,
    created_at INT NOT NULL,
    updated_at INT NOT NULL,
    deleted_at INT,
    is_dirty BOOLEAN DEFAULT 0,
    FOREIGN KEY(contact_id) REFERENCES contacts(id)
);
```

## 5. UI/UX Specifications (The "Delight" Layer)

To achieve the "Delightful" requirement, the app must move away from standard system table views.

### 5.1 Animations
* **Hero Transitions:** When tapping a contact card in the Daily Deck, the avatar should "fly" (Hero transition) to the top of the detail screen.
* **Completion Celebration:** When the "Daily Deck" is cleared (0 tasks remaining), trigger a subtle particle effect (e.g., confetti) or a specific "All Done" illustration.
* **Swipe Interactions:**
    * **Swipe Right:** Quick Log (Mark as "Just said hi").
    * **Swipe Left:** Snooze/Dismiss.

### 5.2 Haptics
* **Completion:** Trigger `HapticFeedback.mediumImpact()` when marking an interaction as done.
* **Selection:** Trigger `HapticFeedback.selectionClick()` when scrolling date pickers or snapping carousels.

### 5.3 Empty States
* **Rule:** Never show a blank white screen.
* **No Contacts:** Show a primary action button "Import from Phone" accompanied by an illustration.
* **No Tasks:** Show a "Relax, you're a good friend!" message with a calming graphic (e.g., a plant or coffee cup).

---

## 6. Future Roadmap (Post-MVP)

### 6.1 Backend Synchronization
* **Goal:** Enable multi-device support.
* **Strategy:** Implement a backend (Go/Node) that accepts "Dirty" records via REST/gRPC.
* **Conflict Resolution:** Last-Write-Wins (LWW) based on the `updated_at` timestamp.

### 6.2 Smart Enrichment
* **Goal:** Reduce manual data entry.
* **Implementation:** Fetch public information (e.g., Twitter/LinkedIn avatar and bio) based on the contact's email address (requires external API integration).

### 6.3 Gift Tracking
* **Goal:** Solve the "What do I get them?" problem.
* **Implementation:** A dedicated "Gifts" tab in the user profile to log ideas throughout the year and mark them as "Given" with a date.

### 6.4 Contact Relationships
* **Goal:** Model social graphs between contacts.
* **Implementation:** A `contact_relationships` table storing graph links (e.g., "Partner of [Contact ID]", "Child of [Contact ID]") to show family/friend connections.
