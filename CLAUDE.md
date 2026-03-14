# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Educational 2D side-scrolling game about Portuguese Great Navigations, built in Godot 4.6.1 with GDScript. Player controls a young cartographer through 5 phases (only Phase 1 implemented). Resolution: 320x180, upscaled 3x to 960x540. All visuals are currently ColorRect placeholders.

## Running the Project

```bash
# Run the game
godot --path grandes_navegacoes/

# Open in editor
godot --path grandes_navegacoes/ --editor

# Import resources (first time)
godot --headless --import --path grandes_navegacoes/

# Run a specific scene
godot --path grandes_navegacoes/ scenes/puzzles/compass_puzzle.tscn

# Validate scripts
godot --headless --check-only --path grandes_navegacoes/
```

Godot is installed via mise at `~/.local/share/mise/installs/godot/4.6.1-stable/godot`.

## Architecture

### Autoload Singletons (registered in project.godot)

Three global managers accessible from any script:

- **GameManager** (`scripts/autoload/game_manager.gd`) — Central state: `current_phase`, `inventory` (Array[Dictionary]), `objectives_completed` (Dictionary of phase → objective → bool), `minimap_revealed`. Handles save/load to `user://save_data.json`. Emits `objective_completed`, `item_collected`, `phase_changed` signals.
- **AudioManager** (`scripts/autoload/audio_manager.gd`) — Music with fade transitions, one-shot SFX with auto-cleanup. Volume properties auto-convert to dB.
- **SceneManager** (`scripts/autoload/scene_manager.gd`) — CanvasLayer (layer 100) with black overlay for fade transitions between scenes. Prevents overlapping transitions.

### Scene Flow

```
Title Screen → Main (loads Fase1Sagres) → [3 Puzzles in sequence] → Phase Complete → Title
```

Pause menu (ESC) overlays as modal CanvasLayer, pauses game tree.

### Player System (`scenes/player/`)

CharacterBody2D with 4-state enum: `EXPLORING`, `IN_PUZZLE`, `IN_DIALOG`, `IN_SHIP`. Only `EXPLORING` allows movement. Interaction via `InteractionArea` (Area2D) that detects nodes in group `"interactable"` and calls their `interact()` method on E press.

### Puzzle Architecture (`scenes/puzzles/`)

Each puzzle is a standalone scene (no direct reference to the level). Communication happens exclusively through `GameManager.complete_objective(phase, objective_key)`. All puzzles auto-return to `fase1_sagres.tscn` after completion. Puzzle gating (ordering) is enforced in `scenes/levels/fase1_sagres.gd`.

Phase 1 objective keys: `"bussola_ventos"`, `"caravela"`, `"astrolabio"` (must be completed in this order).

### Dialog System (`scenes/ui/dialog_box.gd`)

JSON-based dialogs loaded from `data/dialogs/fase1.json`. Format: `{"dialog_id": [{"speaker": "", "text": "", "portrait": ""}]}`. Typewriter effect at 0.03s/char. Two entry points: `start_dialog(id)` loads from JSON, `start_dialog_direct(lines)` takes an array directly. Dialog box registers in group `"dialog_box"` for discovery by NPCs.

### Collision Layers

| Layer | Name | Used By |
|-------|------|---------|
| 1 | World | Ground, rocks |
| 2 | Player | Player body |
| 3 | NPCs | NPC bodies |
| 4 | Interactables | Puzzle triggers, interactive objects |
| 5 | Collectibles | Map items in ship puzzle |

### Input Actions

`move_left/right/up/down` (WASD), `jump` (Space), `interact` (E), `open_map` (F), `pause` (ESC), `ui_accept` (Enter/Space).

## Key Conventions

- **Interactable objects** must: be in the `"interactable"` group and implement an `interact()` method.
- **Puzzle triggers** use `scenes/levels/puzzle_trigger.gd` — a reusable Area2D that emits `triggered` signal on interact.
- **NPC dialog** uses exported `dialog_id` property matching a key in the fase JSON file.
- **Scene transitions** always go through `SceneManager.change_scene()` for consistent fade effects.
- **State changes** always go through `GameManager` signals — HUD and level scripts react via signal connections.
- Rendering uses `default_texture_filter=0` (nearest neighbor) for pixel art crispness.

## Status Tracking

`STATUS.md` tracks implementation progress. Phases 2-5 are mapped but not implemented. Current placeholder items: sprites, fonts, audio assets, flag animations.
