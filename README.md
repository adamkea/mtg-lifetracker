# MTG Life Tracker

A Flutter app for tracking life points in Magic: The Gathering. Supports 1–6 players with a customisable starting life total, hold-to-repeat life controls, and a full undo history.

## Features

- **1–6 players** — adaptive grid layout that fills the screen at any count
- **Custom starting life** — quick presets (20 / 30 / 40) or any value up to 999
- **+1 / −1 / +5 / −5 buttons** — tap once or hold for rapid changes
- **Undo history** — up to 50 steps; an entire hold sequence counts as one undo step
- **Rename players** — double-tap any player name
- **Add / remove players mid-game** — both actions are undoable
- **Persistent settings** — last-used player count and life total are remembered between sessions
- **Dark MTG-themed UI** — high-contrast 80sp life totals readable across a table

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.3.0

### Run the app

```bash
git clone <repo-url>
cd mtg-lifetracker

# Generate platform folders if they don't exist yet
flutter create . --platforms=android,ios

flutter pub get
flutter run
```

## Project Structure

```
lib/
  main.dart                    # App entry point, theme, Provider root
  models/
    player.dart                # Immutable Player data class
    game_state.dart            # ChangeNotifier — all game logic and undo stack
  screens/
    setup_screen.dart          # New-game configuration (player count + life total)
    game_screen.dart           # Main tracker screen with adaptive player grid
  widgets/
    player_card.dart           # One player's panel (name, life total, controls)
    life_control_button.dart   # +/− button with hold-to-repeat behaviour
    undo_bar.dart              # Bottom bar with last-action label and UNDO button
    player_name_dialog.dart    # Dialog for renaming a player

test/
  game_state_test.dart         # Unit tests for GameState logic
```

## Architecture

State is managed by a single `GameState` (`ChangeNotifier`) provided at the app root via the `provider` package. `Player` is an immutable data class; every mutation returns a new instance via `copyWith`, which keeps the undo history stack trivially correct — each snapshot is a shallow copy of the players list.

### Undo history

- `changeLife`, `addPlayer`, and `removePlayer` each push a complete snapshot before applying the change.
- Holding a life-control button pushes **one** snapshot on the initial press; subsequent rapid-fire ticks use `changeLifeNoHistory`. This means one undo step always reverts an entire hold gesture.
- The stack is capped at 50 entries.

## Running Tests

```bash
flutter test
```

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.2 | State management |
| `shared_preferences` | ^2.3.2 | Persist last-used settings |
