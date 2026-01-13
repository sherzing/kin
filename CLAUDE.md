# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Kin** is a local-first mobile personal relationship manager (personal CRM) built with Flutter. It helps users maintain personal relationships through a "Daily Deck" of prioritized contacts and interaction logging.

## Tech Stack

- **Framework:** Flutter (Dart)
- **Database:** SQLite via `drift` (type-safe SQL with migrations)
- **State Management:** `flutter_riverpod`
- **Navigation:** `go_router`
- **Markdown Rendering:** `flutter_markdown`
- **ID Generation:** `uuid` (UUIDs required for future sync support)

## Build Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Generate Drift database code
dart run build_runner build

# Watch mode for code generation
dart run build_runner watch

# Analyze code
flutter analyze

# Format code
dart format .
```

## Architecture Guidelines

### Database Design (Critical)

- **Primary Keys:** Always UUID v4 strings (never auto-increment integers)
- **Soft Deletes:** Set `deleted_at` timestamp instead of deleting rows
- **Dirty Flags:** Use `is_dirty` boolean to track unsynced local changes
- These patterns are required to support future cloud synchronization

### Core Data Models

- **contacts:** People to stay in touch with (name, avatar, phone, email, birthday, job_title, cadence_days, last_contacted_at, snoozed_until)
- **circles:** Tags/groups for organizing contacts (e.g., #family, #college) with optional color_hex
- **contact_circles:** Junction table for many-to-many contact-circle relationships
- **interactions:** Logged conversations/meetings with contacts (type, content as Markdown, is_preparation, happened_at)

### Key Features to Implement

- **Daily Deck:** Card-based home screen showing contacts due for contact based on cadence
- **Health Rings:** Visual status indicator (green/yellow/red) around avatars
- **Interaction Logging:** Support for Call, Meetup, Message, Email, Gift types
- **Markdown Notes:** Rich text with mobile-friendly toolbar shortcuts

## Testing Requirements

Follow Test-Driven Development (TDD):
1. **Write tests first** before implementing functionality
2. **Red-Green-Refactor:** Write a failing test, make it pass, then refactor
3. **All functionality must have tests** - no feature is complete without corresponding test coverage

Test organization:
- Unit tests for all business logic, repositories, and providers
- Widget tests for UI components
- Integration tests for critical user flows (Daily Deck, interaction logging)

Run `flutter test` before committing to ensure all tests pass.

## Issue Tracking

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Session Completion Checklist

Before ending a work session, you MUST:
1. File issues for remaining work
2. Run quality gates (tests, linters) if code changed
3. Update issue status
4. Push to remote: `git pull --rebase && bd sync && git push`
5. Verify `git status` shows "up to date with origin"
