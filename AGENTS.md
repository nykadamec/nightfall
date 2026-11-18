# AGENTS.md — standing rules for AI coding agents

This repository is a solo hobby game: an isometric 2D survivor-like (Vampire Survivors–style) built in Godot. The human (Dominik) is a Godot beginner. Follow this file on every task. The work plan, checklists, and changelog live in `ROADMAP.md`.

## Engine and language

- **Engine: Godot 4.8-beta3**, standard (non-.NET) build, **GDScript only**. Record the exact binary version string in `VERSION.txt` (from `godot --version`) and do not silently switch builds.
- This is a **beta**. Official snapshots can regress or, in rare cases, corrupt a project. Commit often, never work without git, and keep the `.godot/` folder untracked. Do not upgrade or downgrade the engine mid-task. When 4.8-stable (or an RC) ships, **ask the human** before migrating.
- Use only **documented Godot 4.x APIs**. Do not invent 4.8-only features, nodes, or CLI flags. If something might be version-specific, verify it against the pinned editor (`godot --help`, in-editor docs) or ask.
- **GDScript with static typing is mandatory.** Every variable, parameter, and return value has a type. Prefer `:=` when the type is obvious, otherwise write the type explicitly. Enable typed warnings as errors in project settings when you set the project up (`gdscript/warnings`). No untyped `var x`, no untyped collections when a typed alternative exists (`Array[Enemy]`, `Dictionary` only when the schema is genuinely open).
- `class_name` on every reusable entity script (player, enemies, weapons, pickups, resources).

## Repository workflow

- Work **one roadmap task at a time** (for example `T1.3`). Do not start the next task in the same commit.
- Branch or commit naming: `t1.3-isometric-tilemap` (task id + short slug).
- **One task = one commit** (a PR if the human is using a remote). Commit message starts with the task id: `T1.3 Add isometric TileMapLayer arena with collision and Y-sort`.
- After every task, before the commit:
  1. `godot --version` matches the pinned 4.8-beta3 string in `VERSION.txt`.
  2. Import check: `godot --headless --path . --import` (confirm the flag with `godot --help` on the pinned binary; the goal is a clean import and a zero exit code).
  3. Headless smoke: `godot --headless --path . --quit-after 2` once a main scene exists, **and** any tests named in that task’s acceptance criteria (GUT / a `res://scripts/ci/` script).
  4. If a command fails, fix it before committing. Do not “skip CI” to mark the task done.
- After the commit, tick the task in the **Progress checklist** in `ROADMAP.md` and append a short entry to the **Changelog** at the bottom of that file.
- **Do not modify art under `res://assets/`** (PNG, WAV, etc.) except for Godot `.import` settings that are required to make an existing file load correctly (texture filter, mipmaps, tileset region, loop on audio). Do not replace, crop, restyle, or generate over existing concept art unless the human explicitly asks. The pack is already sliced; the inventory, sizes, TileSet steps and NinePatch margins are in `assets/ASSETS.md`. A contact sheet is `assets_preview.png` at the project root. Leave `assets/_source/` alone (original sheets and raw slices).
- **Ask the human** when a design decision is needed (feel of isometric movement, damage numbers, weapon roster, run length, economy, name of the game, scope cuts). Do not silently pick a controversial default and bury it in code. Placeholders are fine if you label them and record the question in the changelog.
- Keep the MVP small. If a task tempts you to add a new system that is not in the current phase, stop. Put the idea in the cut / later list, do not build it.
- Comments and code should be clear enough for a beginner to read. Prefer simple, explicit code over clever abstractions. No general-purpose frameworks “for later”.

## Folder structure

Use this layout. Do not invent parallel roots (`src/`, `code/`, `prefabs/`).

```
res://
  scenes/
    actors/          # player, enemies, boss
    world/           # arena, tiles, spawners, pickups
    weapons/         # weapon scenes (whip arc, projectile)
    vfx/             # hit flash, gems, floating text
    ci/              # headless smoke scenes, if any
  scripts/
    actors/
    combat/
    systems/         # spawner, run timer, xp, pooling helpers
    ui/
    resources/       # Resource class scripts (WeaponData, EnemyData, …)
    autoload/
    ci/              # smoke_test.gd and similar
  resources/         # .tres data only (no scripts)
    weapons/
    enemies/
    upgrades/
    waves/
  assets/            # imported art and audio only
    tiles/
    characters/
    ui/
    audio/
  ui/                # menus, HUD, theme, 9-slice panels
    theme/
  export/            # local export output; gitignore this
```

`project.godot`, `VERSION.txt`, `AGENTS.md`, `ROADMAP.md`, `.gitignore`, and (later) export presets stay at the project root. Test scripts live under `scripts/` (and `addons/gut/` if GUT is installed).

## Naming conventions

- **Files and folders:** `snake_case` — `player.tscn`, `player.gd`, `whip_weapon.tres`, `event_bus.gd`.
- **`class_name` and node names in the scene tree:** `PascalCase` — `Player`, `Hurtbox`, `WeaponMount`.
- **Functions, signals, variables, properties:** `snake_case`. Signals are phrased as things that already happened: `health_depleted`, `enemy_died`, `xp_collected`.
- **Constants and enum members:** `CONSTANT_CASE`.
- **Autoload names** (the singleton name in Project Settings): `PascalCase` matching the class, e.g. `EventBus`, `RunState`, `PoolManager`, `SaveManager`, `AudioManager`.
- One primary script per scene, attached to the root, with the same stem: `scenes/actors/player.tscn` + `scripts/actors/player.gd`.

## Scene and node conventions

- **One scene per entity.** Player, each enemy type, pickups, projectiles, UI screens, and the arena are packed scenes, not nodes hand-built only inside `main.tscn`. Instance them.
- Prefer composition: hitboxes and hurtboxes are child `Area2D` nodes with their own `CollisionShape2D`, not ad-hoc checks in `_physics_process`.
- Gameplay bodies: `CharacterBody2D` for the player and walking enemies. Use `Area2D` for hitboxes, hurtboxes, pickups, and whip/slash volumes. Do not use `RigidBody2D` for this game.
- **Y-sort:** put the player, enemies, world objects, and the isometric `TileMapLayer` under a shared `Node2D` with `y_sort_enabled = true`. Also enable Y-sort on the `TileMapLayer`. Do not use a deprecated workflow if the pinned editor already prefers `y_sort_enabled` on `Node2D`.
- **Isometric map:** `TileMapLayer` + a `TileSet` with isometric tile shape (the 4.x `TileSet` isometric tile shape / diamond layout). **This pack uses tile size 128×64** (atlas `assets/tiles/tileset_iso_blocks.png`, region 128×81). Physics stay in cartesian world space; do not assume a special isometric physics engine. Setup steps are in `assets/ASSETS.md`.
- Camera: one `Camera2D` (usually on the player or a follower). Current, with a small drag/smoothing once the prototype moves.
- Input: use named actions in the Input Map (`move_left`, `move_right`, `move_up`, `move_down`, `pause`, `ui_accept`, `ui_cancel`). Never hard-code scancodes in gameplay code.

### Collision layers (keep this table)

Set these in project settings and reuse them everywhere. Do not invent extra layers without updating this file.

| Layer | Name        | Used by                                      |
|------:|-------------|------------------------------|
| 1     | world       | tile collision, props        |
| 2     | player      | player body                  |
| 3     | enemies     | enemy bodies                 |
| 4     | player_hit  | player weapon hitboxes       |
| 5     | enemy_hit   | enemy contact / attack boxes |
| 6     | pickups     | gems, coins, chicken         |

Masks: player body collides with world + enemy_hit; enemies with world + player_hit; pickups with player (and later a pickup-radius area). Weapon hitboxes do not collide with world unless a specific weapon needs it.

## Data-driven design

- Tunable gameplay data lives in **custom `Resource` types** + `.tres` files, not magic numbers scattered in scene roots (exported inspector knobs on a Resource are fine).
- Expected early Resource types: `WeaponData`, `EnemyData`, `UpgradeData`, `WaveTable`, `PassiveData`. Scripts for those classes live in `res://scripts/resources/`; instances in `res://resources/`.
- Changing a bat’s HP or a whip’s cooldown should not require editing `enemy.gd` logic.

## Autoloads

Only these singletons. Add a new one only if a task in `ROADMAP.md` says so, and document it here in the same change.

| Singleton     | Script                                  | Role |
|---------------|-----------------------------------------|------|
| `EventBus`    | `scripts/autoload/event_bus.gd`         | Global signals only. No gameplay state. |
| `RunState`    | `scripts/autoload/run_state.gd`         | Current run: time, XP, level, HP, gold this run, loadout. Reset on a new run. |
| `PoolManager` | `scripts/autoload/pool_manager.gd`      | Object pools for enemies, projectiles, pickups, floating text. Introduced when the roadmap reaches pooling; until then, keep a stub or wait for that task. |
| `SaveManager` | `scripts/autoload/save_manager.gd`      | Meta progression via `ConfigFile` or `FileAccess` (user://). Not in autoload until Phase 5 unless a stub is useful. |
| `AudioManager`| `scripts/autoload/audio_manager.gd`     | SFX / BGM. Phase 6. |

`EventBus` is the default way systems talk across scenes (spawner, HUD, level-up UI, death screen). Do not look up `/root/Main/Player` from unrelated scripts.

## Signals over direct references

- Child nodes may use `@onready` and the parent may connect to its own children. Cross-system communication goes through **signals** (`EventBus` or a locally exported node + signal), not `get_node("/root/...")` chains.
- Do not tightly couple enemies to the HUD, or the spawner to a concrete player node path. Enemies can receive a `target: Node2D` or find the player once via a group (`player`) if needed.

## Object pooling

- Enemies, projectiles, XP gems, and damage numbers must go through `PoolManager` once that task lands (Phase 3). After that, do not `queue_free()` them on death; release them back to the pool. Until pooling exists, `queue_free()` is acceptable for the prototype so Phase 1–2 stay simple.
- Pools are prefilled on run start. Never allocate a new enemy every spawn after pooling is in.

## UI

- One `Theme` resource under `ui/theme/`, shared by all menus and HUD. Panel chrome uses `NinePatchRect` or `StyleBoxTexture` (9-slice), matching the gothic UI kit (stone gray, deep purple, gold).
- Level-up UI and menus use `process_mode = PROCESS_MODE_ALWAYS` (or `WHEN_PAUSED` as appropriate) so they work while the tree is paused.
- Keep UI scenes in `res://ui/`, not mixed into actor scenes.

## Art pack (already sliced)

- Game-ready PNGs live under `res://assets/{tiles,props,characters,pickups,ui}` and are documented in `res://assets/ASSETS.md`.
- **Tile size is 128×64** (isometric 2:1). The main atlas is `assets/tiles/tileset_iso_blocks.png` with a **128×81** texture region (extra height = tile sides). Props on that sheet are already scaled to the same ratio as the tiles. Player target height is 112 px; pickups are smaller on purpose.
- **Import:** project default texture filter **Nearest**, mipmaps **off**, lossless/uncompressed. See T0.7 and `assets/ASSETS.md`.
- **No animation frames exist.** Use facing textures for the player (`player_sw`, `player_se`, `player_n`, `player_w`) and a bob/squash tween as a placeholder. Do not invent walk cycles or extra sheets.
- UI 9-slice margins are listed in `assets/ASSETS.md` (visually checked). Mid-edge gems on panels will smear if you stretch a lot.
- Mockups in `assets/ui/mockups/` are reference (and at most a backdrop). The main-menu mockup already has a logo and buttons painted in.
- Werewolf, mushroom, and chest sprites exist but stay on the v1 cut list unless the human expands scope.

## Performance (survivor-like)

- This genre spawns hundreds of enemies. After the core loop works: pooling, avoid heavy work per enemy per frame (no pathfinding grid for MVP — steer toward the player), minimize per-frame allocations, prefer simple `move_and_slide` and overlap queries.
- Do not turn on expensive debug drawing in shipped scenes.

## Saving

- Meta save only (unlocks, gold, settings), in `user://` with `ConfigFile` or `FileAccess`. Never write under `res://`.
- A run in progress does not need a mid-run save for MVP.

## What “done” means for a task

A task is done only when its **acceptance criteria** in `ROADMAP.md` pass (automated when possible, otherwise a clearly described manual check for the human). Update the checklist and changelog in the same change.

## Asking the human

Ask, then wait, when you would otherwise decide:

- Game name / itch.io identity (working title is a placeholder).
- Combat feel (isometric movement mapping, invulnerability frames, knockback).
- Which weapons, passives, or enemy types to cut if time slips.
- Engine upgrade off 4.8-beta3.
- Any change to art in `assets/`, audio licensing, or export identity (icon, name).
- New systems not in the current phase.

Write questions briefly, in Czech if you are talking to Dominik, and list the options plus your recommendation.
