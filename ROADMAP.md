# Roadmapa — izometrický survivor (pracovní název: Nightfall)

Tento dokument je především **plán pro AI kódovacího agenta**, který hru staví v Godotu. Dominik rozhoduje o designu, po každé fázi hru spustí a odškrtává, co si ověřil ručně. Pravidla projektu (složky, typování, commity, testy) jsou v `AGENTS.md`.

**Rámec:** sólo hobby projekt, do 10 hodin týdně, Godot **4.8-beta3**, GDScript, cíl **itch.io**. Realistický odhad k malému, hratelnému vydání je **zhruba 6–9 měsíců**. Koncept umění a UI je už **rozřezaný na PNG** v `assets/` (viz `assets/ASSETS.md` a náhled `assets_preview.png`): izometrické dlaždice 128×64, rekvizity, hrdina ve 4 směrech, nepřátelé, předměty a UI komponenty. Zdroje jsou AI JPG, ne čistá pixel-art mřížka; v Godotu použij Filter Nearest. **Žádné animační snímky nejsou** — zástupně bob/squash tween. Agent má držet **MVP malé**: jedna postava, jedna aréna, bič + dvě další zbraně, několik pasiv, čtyři typy nepřátel + jeden boss, běh na čas, smrt a restart, jednoduchá meta za zlato.

**Jak s tím pracovat:** agent bere vždy **jeden úkol** (např. T1.3), po splnění akceptačních kritérií udělá commit, spustí headless kontrolu, odškrtne úkol v checklistu a připíše řádek do changelogu. Když je potřeba designové rozhodnutí, má se zeptat. Úkoly níže jsou v angličtině, aby je agent provedl přesně; sekce **„Co si ověřit ručně“** na konci každé fáze jsou česky pro tebe.

---

# Development roadmap (for the coding agent)

Working title: **Nightfall** (placeholder — confirm with the human before any public page). Genre: isometric 2D survivor-like. Art direction: dark gothic pixel art (stone gray, deep purple, gold).

**Pinned engine:** Godot **4.8-beta3**, standard GDScript build (not .NET). Beta snapshot published 9 November 2026, built from commit `c51ff06e8` (official blog: [Dev snapshot: Godot 4.8 beta 3](https://godotengine.org/article/dev-snapshot-godot-4-8-beta-3/)). Download only from the official archive: https://godotengine.org/download/archive/4.8-beta3/

**Beta risks.** This is pre-release software. Pin the binary, put the version string in `VERSION.txt`, use git from hour one, and never upgrade mid-task. Do not rely on unverified 4.8-only APIs — use documented Godot 4.x features (`TileMapLayer`, `CharacterBody2D`, `Area2D`, signals, `Resource`, autoloads, `Theme` / `NinePatchRect`, `ConfigFile` / `FileAccess`, HTML5 / Windows export).

**Cadence:** about 10 hours/week. Phase estimates are rough, not contracts. Slip is expected; cut content before adding systems.

| Phase | Focus | Weeks @ ~10 h | Cumulative |
|------:|-------|---------------|------------|
| 0 | Setup and learning | 2–3 | weeks 1–3 |
| 1 | Core prototype | 3–4 | weeks 4–7 |
| 2 | Core loop | 4–5 | weeks 8–12 |
| 3 | Content (MVP roster) | 5–6 | weeks 13–18 |
| 4 | Art and UI integration | 3–4 | weeks 19–22 |
| 5 | Meta progression and save | 3–4 | weeks 23–26 |
| 6 | Juice, audio, polish | 3–4 | weeks 27–30 |
| 7 | itch.io release | 2–3 | weeks 31–33 |

That is about **7–8 months** in the middle of the 6–9 month range. If a phase overruns, cut from the Phase 3 roster or the cut list — do not invent a Phase 8 of new features.

## Agent workflow (every task)

1. Read `AGENTS.md` and the target task below. Implement **only** that task.
2. Create the files/nodes listed. Stay inside the folder and naming rules.
3. Run the **acceptance criteria**. Minimum bar after every task:
   - `godot --version` matches `VERSION.txt`.
   - `godot --headless --path . --import` (confirm the exact flag with `godot --help` on the pinned binary) exits 0.
   - Once a main scene exists: `godot --headless --path . --quit-after 2` exits 0.
   - Plus any test script or GUT case the task names.
4. One commit whose message starts with the task id.
5. Tick the progress box and append a **Changelog** line in this file.
6. Stop. Do not start the next task in the same change.
7. Never edit art under `res://assets/` except `.import` settings. Ask the human for design decisions.

---

## Progress checklist

Update the `[ ]` to `[x]` when the task’s acceptance criteria have passed. Counts are for a quick overall picture.

- Overall: `44 / 48` tasks
- Phase 0: `7 / 7` · Phase 1: `7 / 7` · Phase 2: `7 / 7` · Phase 3: `8 / 8`
- Phase 4: `6 / 6` · Phase 5: `4 / 4` · Phase 6: `5 / 5` · Phase 7: `0 / 4`

### Phase 0

- [x] T0.1 Pin Godot 4.8-beta3 and record the version
- [x] T0.2 Git repository, `.gitignore`, root docs
- [x] T0.3 Project skeleton and `project.godot` defaults
- [x] T0.4 Autoload stubs (`EventBus`, `RunState`)
- [x] T0.5 Headless smoke script (and GUT if it installs cleanly)
- [x] T0.6 Empty isometric main scene
- [x] T0.7 Import the sliced asset pack and set Nearest filters

### Phase 1

- [x] T1.1 Player movement
- [x] T1.2 Follow camera
- [x] T1.3 Isometric arena, collision, Y-sort
- [x] T1.4 One chasing enemy
- [x] T1.5 Contact damage and player HP
- [x] T1.6 Auto-attack whip
- [x] T1.7 Enemy HP and death

### Phase 2

- [x] T2.1 XP gems
- [x] T2.2 XP curve and level-up signal
- [x] T2.3 Three-card level-up choice (pause + apply)
- [x] T2.4 Reroll and skip
- [x] T2.5 Wave spawner
- [x] T2.6 Run timer and HUD
- [x] T2.7 Death screen and restart

### Phase 3

- [x] T3.1 `WeaponData` and weapon controller
- [x] T3.2 Two additional weapons
- [x] T3.3 Passives
- [x] T3.4 Data-driven `EnemyData`
- [x] T3.5 Two more enemy types (four total)
- [x] T3.6 Boss at a set time
- [x] T3.7 Object pooling
- [x] T3.8 Chicken and coin pickups

### Phase 4

- [x] T4.1 Import tileset and apply to the map
- [x] T4.2 Character sprites and animations
- [x] T4.3 Theme and 9-slice UI
- [x] T4.4 Main menu
- [x] T4.5 Level-up card UI
- [x] T4.6 HUD and boss bar polish

### Phase 5

- [x] T5.1 Save/load gold and settings
- [x] T5.2 Meta unlocks
- [x] T5.3 Options menu
- [x] T5.4 Run summary

### Phase 6

- [x] T6.1 Combat juice
- [x] T6.2 Sound effects
- [x] T6.3 Music
- [x] T6.4 Game-over / menu polish
- [x] T6.5 Performance pass

### Phase 7

- [ ] T7.1 Export presets (Windows + Web)
- [ ] T7.2 Playtest and bugfix pass
- [ ] T7.3 itch.io package and page copy
- [ ] T7.4 Release checklist and engine-upgrade question

---

## Scope tips (keep the MVP small)

Ship a **short, fair, readable run**: one hooded whip hunter, one graveyard arena, start with the whip, unlock two more weapons, 3–4 passives, four enemy types (bat, skeleton, zombie, ghost), one vampire-lord boss at the end of a 10–15 minute timer, XP gems, chicken (heal), coins for meta, 3-card level-up with limited reroll + skip, death → summary → retry / menu, Windows and HTML5 builds on itch.io.

**Cut list (do not build for v1):** character select; extra biomes (lava, castle floors as a second map); werewolf and mushroom enemies; weapon evolutions; lucky chests / item draft; mid-run saves; endless mode; achievements and leaderboards; mobile ports; Steam / gamepad-perfect polish beyond basic Input Map actions; localization pipelines; New Game+. If time is short, cut the third weapon or the fourth enemy before adding any of the above.

The sliced art pack in `assets/` is ready from Phase 0 (T0.7). Phase 1–3 should use those PNGs, not new placeholder rectangles. Do not overwrite pack files. Phase 4 is for Theme / 9-slice / menu wiring, not for redrawing art.

---

## Phase 0 — Setup and learning (2–3 weeks)

**Milestone / definition of done:** The project opens in the pinned Godot 4.8-beta3 editor, the folder layout exists, git history is clean, autoload stubs load, a headless import + smoke command exits 0, and the sliced art pack in `res://assets/` is imported with Nearest filtering (see T0.7 and `assets/ASSETS.md`).

### T0.1 Pin Godot 4.8-beta3 and record the version

- **Goal:** Everyone (human and agent) runs the same editor binary.
- **Files / nodes:** `VERSION.txt`; a short “Engine” section in `README.md` (create the README if needed).
- **Implementation notes:** Install the official **standard** (non-.NET) 4.8-beta3 build. Run `godot --version` and store the exact string. Mention beta risk and the official download URL. Do not add the engine binary to git.
- **Acceptance criteria:** `VERSION.txt` is non-empty; `godot --version` output matches it; README tells a beginner where to get that build.
- **Dependencies:** none.

### T0.2 Git repository, `.gitignore`, root docs

- **Goal:** Version control from the first project file, with Godot cruft untracked.
- **Files / nodes:** `.gitignore` (must ignore `.godot/`, `export/`, OS junk, `.import` only if you explicitly decide otherwise — usually **commit** `*.import` so assets load the same everywhere, and ignore `.godot/`); `README.md` if not already created.
- **Implementation notes:** Use a standard Godot 4 gitignore. Initial commit may include `AGENTS.md` and this roadmap. No secrets, no editor binary.
- **Acceptance criteria:** `git status` is clean after the first commit; `.godot/` is not tracked; cloning the repo does not require committing imported caches.
- **Dependencies:** T0.1 recommended first so the README can cite the pinned version.

### T0.3 Project skeleton and `project.godot` defaults

- **Goal:** Create the Godot project and the folder tree in `AGENTS.md`.
- **Files / nodes:** `project.godot`; empty folders under `res://scenes`, `scripts`, `resources`, `assets`, `ui` (add `.gdkeep` or a tiny `README` in empty dirs so git tracks them).
- **Implementation notes:** Renderer: Compatibility (better for HTML5 on itch.io later — if you change this, ask the human). Viewport / stretch: 2D, keep a modest base resolution (e.g. 1280×720) and `canvas_items` stretch. Turn on GDScript static typing warnings (treat unsafe / untyped as warnings or errors). Input Map: `move_left/right/up/down`, `pause`. Collision layers named as in `AGENTS.md`.
- **Acceptance criteria:** Project opens in 4.8-beta3 without errors; folders exist; `godot --headless --path . --import` exits 0.
- **Dependencies:** T0.1, T0.2.

### T0.4 Autoload stubs (`EventBus`, `RunState`)

- **Goal:** Global signal bus and a resettable run-state singleton exist and load.
- **Files / nodes:** `scripts/autoload/event_bus.gd`, `scripts/autoload/run_state.gd`; both registered in `project.godot`.
- **Implementation notes:** `EventBus` contains only typed signals (start with `run_started`, `run_ended`, `player_died` — more are added by later tasks). No state. `RunState` holds typed default fields (`time_sec`, `xp`, `level`, `hp`, `max_hp`, `gold`) and a `reset()` method. Do not add `PoolManager` / `SaveManager` yet.
- **Acceptance criteria:** Headless boot does not error; a tiny script or GUT test (if T0.5 already landed, otherwise a method called from the T0.5 smoke script in the next task) can instance/reset `RunState` and see defaults.
- **Dependencies:** T0.3.

### T0.5 Headless smoke script (and GUT if it installs cleanly)

- **Goal:** A repeatable, scriptable check the agent runs after every later task.
- **Files / nodes:** `scripts/ci/smoke_test.gd` (extends `SceneTree` or `MainLoop` as appropriate for a `--script` / `-s` entry). Optionally `addons/gut/` if a Godot 4.x GUT release installs and runs on this beta without patches.
- **Implementation notes:** The smoke script starts, asserts autoloads exist, and `quit` with a non-zero code on failure. If GUT’s AssetLib / addon import fails on the beta, **do not fight it for days** — keep the smoke script as the CI floor and note the issue in the changelog. Ask the human before adding large addons.
- **Acceptance criteria:** `godot --headless --path . -s res://scripts/ci/smoke_test.gd` exits 0. Document the exact command in `README.md`.
- **Dependencies:** T0.4.

### T0.6 Empty isometric main scene

- **Goal:** A main scene the editor and headless boot can run, already set up for isometric tiles and Y-sort.
- **Files / nodes:** `scenes/world/main.tscn` (or `scenes/world/arena.tscn` instanced by `main.tscn`); a `Node2D` World with `y_sort_enabled`; a `TileMapLayer` with an isometric `TileSet`. Prefer `assets/tiles/tileset_iso_blocks.png` (tile size 128×64, region 128×81) if T0.7 is done; otherwise a temporary solid-colour iso grid is fine — never overwrite files already in `assets/tiles/`. Set as the main scene in `project.godot`.
- **Implementation notes:** Prefer the real atlas in `res://assets/tiles/tileset_iso_blocks.png` (tile_size 128×64, region 128×81) once T0.7 has imported it. If T0.7 is not done yet, a temporary solid-colour iso grid is acceptable — do **not** overwrite anything already in `assets/tiles/`. No player yet. Follow `assets/ASSETS.md` for TileSet steps.
- **Acceptance criteria:** Editor runs the main scene; `godot --headless --path . --quit-after 2` exits 0; smoke test still passes.
- **Dependencies:** T0.5. T0.7 may be done before or just after this; if the pack is already imported, use it here instead of placeholders.

### T0.7 Import the sliced asset pack and set Nearest filters

- **Goal:** All game-ready PNGs under `res://assets/` load in the editor with crisp nearest-neighbour filtering, and a `TileSet` resource exists for the isometric atlas.
- **Files / nodes:** Commit Godot `.import` files for the pack; `resources/tilesets/arena_tileset.tres` (name may vary); project setting *Rendering → Textures → Default Texture Filter = Nearest*. Do **not** modify PNG pixels. Skip `assets/_source/` (provenance JPGs, no alpha).
- **Implementation notes:** Follow `assets/ASSETS.md` exactly: mipmaps off, lossless (or uncompressed) compress, Fix Alpha Border on is fine. TileSet: isometric, Diamond Down, tile size **128×64**, atlas `assets/tiles/tileset_iso_blocks.png`, texture region **128×81**. Adjust texture origin so the 128×64 footprint sits on the grid. There are **no animation frames** — do not invent sprite sheets.
- **Acceptance criteria:** Opening a test/main scene shows at least two terrain tiles and one prop or the player sprite without blur or missing textures. `godot --headless --path . --import` exits 0. `.import` files for the used PNGs are in git. No files under `assets/` were overwritten.
- **Dependencies:** T0.3. Best before or with T0.6 / T1.1 / T1.3.

**Co si ověřit ručně**

- Godot, který otevíráš, je opravdu **4.8-beta3** (Nápověda → O programu / `godot --version`) a souhlasí s `VERSION.txt`.
- Projekt se otevře bez červených chyb, vidíš prázdnou izometrickou mřížku (i když jen barevné kosočtverce).
- Změna v nějakém textovém souboru a `git status` / commit funguje; složka `.godot/` v gitu není.
- Přečti si `AGENTS.md` aspoň zběžně — je to smlouva, podle které agent commituje.
- Po T0.7: dlaždice a hrdina v editoru nejsou rozmazaní (Nearest), izometrická mřížka sedí. Náhled všech výřezů je v `assets_preview.png`; inventář v `assets/ASSETS.md`.

---

## Phase 1 — Core prototype (3–4 weeks)

**Milestone / definition of done:** You can walk an isometric arena, the camera follows, one enemy chases you, touching it hurts you, and a whip automatically damages and can kill that enemy. No XP, no menu, no waves yet. This is the “it is already a tiny game” cut.

### T1.1 Player movement

- **Goal:** A `CharacterBody2D` player moves with the Input Map actions.
- **Files / nodes:** `scenes/actors/player.tscn`, `scripts/actors/player.gd` (`class_name Player`); instanced in the main/arena scene. `Sprite2D` using the pack in `res://assets/characters/player/` — `player_sw.png`, `player_se.png`, `player_n.png`, `player_w.png` (switch by facing; there is no unique NE pose, see `assets/ASSETS.md`). `CollisionShape2D`. Add the player to group `player`.
- **Implementation notes:** `move_and_slide()` in `_physics_process`. Speed is an `@export` or, better, a temporary constant you will later move to data. **Isometric feel:** world physics are cartesian. A common approach is to map WASD so “up” moves along the isometric axes (e.g. a 2:1 skew). Implement a simple, documented mapping and **ask the human to confirm the feel** after this task — do not spend days tweaking. **No walk cycle exists**; a 2–4 px bob tween is enough as a placeholder. Do not overwrite the PNGs. Player target height is 112 px (already scaled in the pack).
- **Acceptance criteria:** Headless smoke still passes. A short ci script or GUT test can set a mock input or call a `apply_move_for_test(direction: Vector2, delta: float)` and assert `global_position` changes. Manual fallback (if input cannot be mocked yet): documented “human moves with WASD and does not slide forever.”
- **Dependencies:** T0.6.

### T1.2 Follow camera

- **Goal:** `Camera2D` stays on the player.
- **Files / nodes:** `Camera2D` child of the player (or a small follower scene). Enabled as current.
- **Implementation notes:** Light smoothing/drag is optional and should stay subtle. No camera shake yet (Phase 6).
- **Acceptance criteria:** Running the main scene (editor or `--quit-after 2`) has exactly one current camera; no errors. Manual: walking to the map edge keeps the player in view.
- **Dependencies:** T1.1.

### T1.3 Isometric arena, collision, Y-sort

- **Goal:** A bounded walkable arena; walls collide; Y-sort draws the player correctly against tiles/objects.
- **Files / nodes:** `TileMapLayer` using `res://resources/tilesets/arena_tileset.tres` (from T0.7) and `res://assets/tiles/tileset_iso_blocks.png` (tile_size 128×64, region 128×81). Props as instanced scenes with textures from `res://assets/props/` — start with `gravestones_group.png`, `tree_dead.png`, `pillar.png`, `crate.png`, `barrel.png`, `brazier.png`, `fence.png`, `skull_pile.png`. `castle_ruins.png` is a larger prop, not a single tile. Do not draw placeholder floors over the pack.
- **Implementation notes:** Use `TileSet` physics polygons / physics layers on layer `world`. Player collision mask includes `world`. Keep the map small (one screen or two), preferably a graveyard (`tile_graveyard_soil` / `tile_cobblestone` / `tile_grass`). No procedural generation. Y-sort the props with the player. See `assets/ASSETS.md` for origin / thickness notes.
- **Acceptance criteria:** A test (or a ci scene) places the player overlapping a wall and, after `move_and_slide`, they are not inside the collider. Headless boot still exits 0. Manual: you cannot walk out of the arena; walking “behind” a tall placeholder changes draw order.
- **Dependencies:** T1.1. Camera (T1.2) may be in parallel but should be merged first if both touch `player.tscn`.

### T1.4 One chasing enemy

- **Goal:** One `CharacterBody2D` enemy (working name: bat) steers toward the player and is blocked by world collision.
- **Files / nodes:** `scenes/actors/enemy_bat.tscn`, `scripts/actors/enemy_base.gd` (shared base, keep it small) and/or `enemy_bat.gd`; placed or instanced once in the arena for this task (no spawner yet). Sprite: `res://assets/characters/enemies/bat.png`.
- **Implementation notes:** No pathfinding. Direction = `player.global_position - global_position`. Target via group `player` or an exported `Node2D`. Speed slower or faster than the player is a feel question — pick a default, ask if it feels wrong. Y-sorted with the player. Static sprite only (no flap frames); a small bob is optional.
- **Acceptance criteria:** Headless ci scene: after N physics frames the enemy’s distance to a stationary player has decreased (start them apart, no walls between). Smoke still passes.
- **Dependencies:** T1.3.

### T1.5 Contact damage and player HP

- **Goal:** Touching the enemy damages the player; HP reaches zero and emits `player_died` (no death screen yet).
- **Files / nodes:** Player `Hurtbox` (`Area2D`, layer/mask per `AGENTS.md`); enemy `Hitbox` (`Area2D`); `RunState.hp` / `max_hp` updated; `EventBus.player_hurt`, `EventBus.player_died`. Brief invulnerability after a hit (export a duration).
- **Implementation notes:** Damage on `area_entered` / a periodic tick while overlapping (document which). Do not kill the player in this task beyond setting HP to 0 and emitting the signal — no reload yet.
- **Acceptance criteria:** GUT or ci script: create player + overlapping enemy hitbox, simulate, assert HP dropped, i-frames prevent instant death in the same instant, and `player_died` fires when HP is set to 0. Headless smoke passes.
- **Dependencies:** T1.4, T0.4.

### T1.6 Auto-attack whip

- **Goal:** A weapon automatically swings on a cooldown and can hit the enemy hurtbox.
- **Files / nodes:** `scenes/weapons/whip_attack.tscn` (an `Area2D` slash volume); `scripts/combat/weapon_controller.gd` or a player-owned `WhipWeapon` node; layer `player_hit`.
- **Implementation notes:** Vampire Survivors–style: on cooldown, enable a short-lived area beside the player (alternate sides or face the nearest enemy — pick nearest-enemy if cheap, else alternate). No projectile. Tunables: damage, cooldown, duration, size — exported, later moved to `WeaponData` (T3.1). Do not build a weapon inventory yet.
- **Acceptance criteria:** Ci/GUT: after a cooldown in a scene with a dummy hurtbox in range, the hurtbox receives a hit signal or a `take_damage` call. Headless smoke passes. Manual: standing next to the enemy, flashes/hits occur without pressing an attack key.
- **Dependencies:** T1.1. Best after T1.4 so there is a target.

### T1.7 Enemy HP and death

- **Goal:** The enemy can die, free itself (pooling comes later), and emit `EventBus.enemy_died`.
- **Files / nodes:** `take_damage(amount: int)` on the enemy base; hook the whip into it; optional tiny placeholder death (just disappear).
- **Implementation notes:** Still one bat in the scene. When dead: emit `enemy_died` with position and an xp value (even if nothing listens yet), then `queue_free()`.
- **Acceptance criteria:** Ci/GUT: enemy at 10 HP takes 10 damage and is queued free / `is_dead`; `enemy_died` is emitted once. The live scene: one bat can be whipped to death. Smoke passes.
- **Dependencies:** T1.6, T1.5 (signal style should match).

**Co si ověřit ručně**

- Šipkami / WASD se hrdina pohybuje po kosočtvercové mapě a **není možné odejít z arény**.
- Kamera ho sleduje, nepřítel jde za tebou, při dotyku **ubývá život** a po chvíli i-frames neublíží hned znovu.
- **Útok běží sám** (bič), nemusíš mačkat tlačítko útoku, a netopýra jde ubít.
- Když ti movement v izometrii přijde divný (jdeš „do strany“ jinak, než čekáš), řekni to — je to záměrně otázka na tebe, ne chyba nutně.

---

## Phase 2 — Core loop (4–5 weeks)

**Milestone / definition of done:** A complete one-run toy loop: enemies (still one type) spawn in waves, drop XP gems, collecting enough XP pauses the game with three upgrade cards (even dummy “+10% damage / +10% speed / +20 HP”), reroll and skip work, a timer is on the HUD with HP and XP, and dying shows a screen that can restart the run.

### T2.1 XP gems

- **Goal:** Dead enemies drop a gem; walking over it adds XP.
- **Files / nodes:** `scenes/world/xp_gem.tscn`, `scripts/world/xp_gem.gd`; listen to `EventBus.enemy_died`; `RunState.xp`; `EventBus.xp_collected`. Sprites: `res://assets/pickups/xp_gem_blue.png` (default), optionally `xp_gem_green.png` / `xp_gem_red.png` for higher values later.
- **Implementation notes:** `Area2D`, layer `pickups`. Spawn at the death position. Magnet / pickup radius is optional and should stay a simple player area if added. `queue_free()` is fine (pooling in T3.7). Gems are already scaled small (~16–28 px tall).
- **Acceptance criteria:** Ci: simulate `enemy_died` → gem spawns → overlap player → `RunState.xp` increases and the gem is gone. Smoke passes.
- **Dependencies:** T1.7.

### T2.2 XP curve and level-up signal

- **Goal:** Crossing an XP threshold increments `RunState.level` and emits `EventBus.level_up`.
- **Files / nodes:** Logic on `RunState` or `scripts/systems/experience.gd`; a tiny function `xp_needed_for(level: int) -> int` (simple curve: e.g. base * level, documented).
- **Implementation notes:** No UI yet. Surplus XP carries over.
- **Acceptance criteria:** GUT/unit test (no scene required): starting at 0, add XP in chunks, assert levels and remainder. Edge: exact threshold and overflow.
- **Dependencies:** T2.1, T0.4.

### T2.3 Three-card level-up choice (pause + apply)

- **Goal:** On `level_up`, the tree pauses and three upgrade options appear; picking one applies and unpauses.
- **Files / nodes:** `ui/level_up/level_up_screen.tscn` + script; 2–3 hardcoded dummy upgrades (damage, move speed, max HP) until Phase 3 resources; `process_mode` so the UI works while paused.
- **Implementation notes:** Offer three distinct options when possible. Applying an upgrade must change a real number the prototype already uses (player speed, whip damage, max HP + heal the delta). Input: mouse click and `ui_accept` if cheap.
- **Acceptance criteria:** Ci: emit `level_up`, assert `get_tree().paused`, simulate choose card 0, assert the stat changed and the tree is unpaused. Manual: play until level-up, pick a card, game continues, the bonus is noticeable.
- **Dependencies:** T2.2.

### T2.4 Reroll and skip

- **Goal:** Level-up screen has **reroll** (limited uses per run or per level-up — pick one, document it, ask if unsure) and **skip** (close with no upgrade).
- **Files / nodes:** Buttons on the level-up screen; `RunState.rerolls_left` or a per-popup counter.
- **Implementation notes:** Reroll must change at least one offered upgrade when other options exist. Skip unpauses and grants nothing. Do not spend gold yet (no economy).
- **Acceptance criteria:** Tests for: skip → no stat change, unpaused; reroll decrements the counter and can change offerings; at 0 rerolls the button is disabled.
- **Dependencies:** T2.3.

### T2.5 Wave spawner

- **Goal:** Enemies spawn around the player over time, off-screen or at the arena rim, using a simple wave table.
- **Files / nodes:** `scenes/world/spawner.tscn`, `scripts/systems/spawner.gd`, `scripts/resources/wave_table.gd` + `resources/waves/early_waves.tres`.
- **Implementation notes:** Data: time window, enemy scene, count, interval, cap. Spawn positions: ring around the player, clamped inside the arena, not on top of the player. Cap the live enemy count (even before pooling) so the prototype cannot explode. Still **one enemy type**.
- **Acceptance criteria:** Ci scene: start spawner with a test wave (count=3, interval short), after N seconds `get_tree().get_nodes_in_group("enemies").size()` is 3 (or capped). Headless `--quit-after` does not explode in errors.
- **Dependencies:** T1.7, T1.3. XP drop (T2.1) should already work with spawned enemies.

### T2.6 Run timer and HUD

- **Goal:** Visible run time, HP, XP / level while playing.
- **Files / nodes:** `ui/hud/hud.tscn`; `RunState.time_sec` incremented while not paused; `EventBus` or direct `RunState` reads (HUD may listen to signals; do not poll through node paths to the player for HP if `RunState` already has it — keep player HP and `RunState.hp` in sync, one source of truth).
- **Implementation notes:** Placeholder labels are fine (art in Phase 4). Timer is the run clock, not a performance FPS counter.
- **Acceptance criteria:** Ci: after 2 simulated seconds unpaused, displayed/stored time is ~2s; a hurt event updates the HP label/value; XP changes update the bar/value. Smoke passes.
- **Dependencies:** T1.5, T2.2.

### T2.7 Death screen and restart

- **Goal:** On `player_died`, pause or stop spawning, show a death screen, and allow **Retry** (reset run, reload main scene) and later **Menu** (menu exists in T4.4 — for now Retry is enough, add a disabled or hidden Menu button if you want the hook).
- **Files / nodes:** `ui/death/death_screen.tscn`; `RunState.reset()`; stop the timer.
- **Implementation notes:** Retry must not leak enemies / gems (free the scene tree by changing scene to main). Do not save anything yet.
- **Acceptance criteria:** Ci or a scripted main-scene test: force `player_died`, death screen visible, Retry results in a fresh `RunState` (xp 0, default HP, time 0) and a living player. Smoke passes.
- **Dependencies:** T2.6, T1.5.

**Co si ověřit ručně**

- Vydržíš alespoň dvě minuty: nepřátelé **přicházejí ve vlnách**, ne jen ten jeden z fáze 1.
- Sbíráš fialové/modré kuličky XP, po čase se hra **pozastaví** a vyskočí **tři karty**. Výběr, přeskočení i reroll se chovají, jak čekáš, a bonus je cítit.
- Nahoře (nebo kde je HUD) běží **čas**, vidíš životy i XP.
- Když tě zabijí, uvidíš **obrazovku smrti** a **Retry** opravdu začne běh znovu od nuly, ne „skoro mrtvý v tom samém chaose“.

---

## Phase 3 — Content, MVP roster (5–6 weeks)

**Milestone / definition of done:** Weapons and enemies are data-driven. The run can roll real upgrades (weapons and passives). Four enemy types are in the wave table, a boss appears at a set time, pickups include chicken and coins, and enemies/projectiles/gems are pooled so a crowded minute still runs.

Stay inside the MVP roster. Do not add werewolf, mushroom, evolutions, or a second map.

### T3.1 `WeaponData` and weapon controller

- **Goal:** The whip (and future weapons) are described by a Resource and owned by a small controller on the player.
- **Files / nodes:** `scripts/resources/weapon_data.gd`, `resources/weapons/whip.tres`, a `WeaponController` that can equip 1+ weapons and tick them. Migrate whip tunables out of hardcoded exports.
- **Implementation notes:** Fields like `id`, `display_name`, `cooldown`, `damage`, `scene`, `max_level`. Level-up cards may later add a weapon or call `upgrade()`. Keep the API boring and typed.
- **Acceptance criteria:** Whip behaviour is unchanged in play, but values come from `.tres`. A unit test loads `whip.tres` and asserts required fields. Headless import + smoke pass.
- **Dependencies:** T1.6, T2.3 (level-up will hook into this).

### T3.2 Two additional weapons

- **Goal:** Two more MVP weapons, distinct in feel, offered on level-up when not yet at cap.
- **Files / nodes:** Two scenes + two `.tres` files (suggestions: a projectile “holy bolt” and a spinning / orbiting aura — confirm names/theme with the human if unsure). Update the level-up pool.
- **Implementation notes:** One new pattern may be a projectile (`Area2D` moving forward, `queue_free` on hit or timeout until T3.7). Keep numbers in Resources. No evolution system.
- **Acceptance criteria:** Each weapon has a ci/GUT hit test similar to the whip. In a dummy level-up, a card can add the weapon and it fires on its own. Smoke passes.
- **Dependencies:** T3.1.

### T3.3 Passives

- **Goal:** 3–4 passives as `PassiveData` (max HP, move speed, pickup radius, cooldown reduction, damage). Level-up can offer them.
- **Files / nodes:** `scripts/resources/passive_data.gd`, `resources/upgrades/*.tres`, an applier on `RunState` or the player.
- **Implementation notes:** Stacking rules: simple additive or multiplicative, documented in the resource. No more than four for MVP.
- **Acceptance criteria:** Unit tests: apply each passive once and assert the affected stat. Play: a level-up can offer a passive and the HUD/stat changes.
- **Dependencies:** T2.3, T3.1 (level-up pool should mix weapons + passives).

### T3.4 Data-driven `EnemyData`

- **Goal:** HP, speed, damage, XP, scene path live in `.tres`, not only in the bat scene.
- **Files / nodes:** `scripts/resources/enemy_data.gd`, `resources/enemies/bat.tres`; enemy base reads the Resource on ready / setup.
- **Implementation notes:** Spawner passes `EnemyData` (or the packed scene referenced by it).
- **Acceptance criteria:** Changing HP in `bat.tres` (in a test resource) changes how many whip hits are required in a ci test. Smoke passes.
- **Dependencies:** T1.7, T2.5.

### T3.5 Two more enemy types (four total)

- **Goal:** Four types in the wave table: **bat, skeleton, zombie, ghost** (werewolf and mushroom stay on the cut list).
- **Files / nodes:** Four packed scenes + four `.tres`. Sprites (already in the pack): `res://assets/characters/enemies/bat.png`, `skeleton.png`, `zombie.png`, `ghost.png`. Do **not** add `werewolf.png` or `mushroom.png` to the v1 wave table (cut list) even though those PNGs exist. Differentiate simply: speed/HP/damage, maybe ghost ignores (or not) some collision — **if** ghost phases through walls, keep it simple and documented; default is “all collide with world” if phasing is messy.
- **Implementation notes:** Use the sliced sprites, not placeholders. Update `WaveTable` so later minutes mix types. Unique scripts only where behaviour differs; share `enemy_base.gd`. Static poses only.
- **Acceptance criteria:** Spawner test can spawn each type. A short headless run (quit-after several seconds) with a dense test wave stays error-free. Manual: you can tell the four types apart (bat, skeleton, zombie, ghost sprites from the pack).
- **Dependencies:** T3.4, T2.5.

### T3.6 Boss at a set time

- **Goal:** At a fixed run time (export, e.g. 10:00), spawn the **vampire lord** once, with a large HP pool and a simple pattern (contact damage is enough; one extra attack if time allows). Emit boss signals for the future boss bar.
- **Files / nodes:** `scenes/actors/boss_vampire_lord.tscn` with `res://assets/characters/enemies/vampire_lord.png` (184×163, already scaled); `resources/enemies/vampire_lord.tres`; `EventBus.boss_spawned`, `boss_hp_changed`, `boss_died`. Boss bar art: `res://assets/ui/components/bar_boss.png` (and optional `_frame` / `_fill` — see `assets/ASSETS.md` for caveats). Optional: ending the run on boss death (victory screen can be a variant of the death/summary screen — if you add “victory”, keep it minimal).
- **Implementation notes:** Ask the human whether beating the boss **wins** the run or only drops loot and the timer continues. Recommended: **boss kill = victory**, then a summary screen. Do not add phases or minion storms for v1.
- **Acceptance criteria:** Ci: set time just before the threshold, advance, assert one boss in the tree and the signal fired; damaging it emits `boss_hp_changed`; at 0 HP it dies once. Smoke passes.
- **Dependencies:** T3.5, T2.6 (timer).

### T3.7 Object pooling

- **Goal:** Enemies, projectiles, XP gems (and damage numbers if already present) are acquired/released via `PoolManager` instead of `instantiate`/`queue_free` on every spawn.
- **Files / nodes:** `scripts/autoload/pool_manager.gd` registered as `PoolManager`; spawner, weapons, and gem drops updated; prefill counts in a small config or exports.
- **Implementation notes:** `acquire(key) -> Node`, `release(node)`. On release: hide, disable physics, reparent to the pool, reset HP/timers. On acquire: re-enable and drop into the Y-sort world. Prefill on `run_started`. Document keys (`enemy_bat`, `xp_gem`, …).
- **Acceptance criteria:** Stress ci: spawn and kill / despawn more than the prefill count in a loop; instance count of that scene type stays near the pool size (no unbounded growth). Existing gameplay tests still pass. Headless smoke passes.
- **Dependencies:** T2.5, T3.2 (projectiles exist), T2.1.

### T3.8 Chicken and coin pickups

- **Goal:** Some deaths (or rare spawns) drop a **chicken** (heal) or a **coin** (run gold). Chests stay on the cut list unless a one-line “touch for gold” crate is trivial — default is **no chest** for MVP.
- **Files / nodes:** `scenes/world/chicken.tscn` (`res://assets/pickups/chicken.png`), `coin.tscn` (`res://assets/pickups/coin.png`); drop chances on `EnemyData` or a tiny loot table Resource. `pickups/chest.png` exists but stays off the v1 loop unless the human asks otherwise.
- **Implementation notes:** Coins add to `RunState.gold` (meta spend is Phase 5). Chicken heals a fixed or percent amount, not above max HP. Use the pool if T3.7 is done.
- **Acceptance criteria:** Unit/ci: pickup chicken at missing HP heals and clamps; coin increments gold; neither crashes when pooled. Smoke passes.
- **Dependencies:** T2.1, T3.4. Prefer after T3.7.

**Co si ověřit ručně**

- V jednom běhu umíš **získat jinou zbraň a nějakou pasivu** z karet, ne jen „+10 % damage“ z prototypu.
- Poznáš **čtyři typy nepřátel**; na stanoveném čase se objeví **boss** a jde ho (třeba s cheaty / v testovacím módu) zabít, nebo aspoň vidíš jeho příchod a životy.
- Při hustší vlně by hra **neměla okamžitě padat na FPS** — pokud jo, napiš to, pooling (T3.7) je k tomu.
- Kuře léčí, mince přibývají; truhly ve v1 záměrně být nemusí.

---

## Phase 4 — Art and UI integration (3–4 weeks)

**Milestone / definition of done:** The already-sliced pack (`assets/ASSETS.md`) is fully wired: tiles and props on the map, hero and enemy static sprites (bob/squash only — there are no walk/attack frames), a `Theme` with 9-slice panels from `assets/ui/components/`, a real main menu, level-up cards matching `ui/mockups/level_up_reference.png`, and a HUD / boss bar in the gothic style.

The agent **only applies** existing PNGs and import settings. It must not redraw or overwrite files in `assets/` except `.import` settings. Mockups in `ui/mockups/` are reference / backdrop only (the menu mockup already has logo and buttons painted in).

### T4.1 Import tileset and apply to the map

- **Goal:** Placeholder floor/walls are replaced with the concept tiles (grass, cobblestone, dirt, graveyard soil, water, gravestones, etc. as available). Lava / castle floor can wait if they belong to cut biomes — prefer **one graveyard arena**.
- **Files / nodes:** Use the existing pack — atlas `assets/tiles/tileset_iso_blocks.png` and the TileSet from T0.7 / T1.3; props from `assets/props/` as listed in `assets/ASSETS.md`. Do not replace those PNGs.
- **Implementation notes:** Tile size is already **128×64** (region 128×81 for the block atlas). Paint a graveyard arena (cobblestone / graveyard soil / grass; water and lava optional). Place `gravestones_group`, tree, fence, brazier, etc. Ask the human only if a needed slice is genuinely missing from the inventory.
- **Acceptance criteria:** Main scene in the editor shows the gothic map; collisions still prevent leaving the arena (re-run T1.3-style test). Import + smoke pass. No placeholder-magenta floors left in the shipping arena.
- **Dependencies:** T1.3. Art must be provided in the repo or by the human.

### T4.2 Character sprites and animations

- **Goal:** Player (hooded whip hunter) and the four enemies + boss use the concept sprites; at least idle and walk (attack/swing if frames exist).
- **Files / nodes:** Player: `assets/characters/player/player_{sw,se,n,w}.png`. Enemies: `assets/characters/enemies/{bat,skeleton,zombie,ghost,vampire_lord}.png` (werewolf/mushroom only if scope changes). No `AnimationPlayer` walk cycle — switch facing textures and use a bob/squash tween (`assets/ASSETS.md`).
- **Implementation notes:** Filter already set in T0.7 (Nearest, no mipmaps). Do not invent frames or overwrite PNGs. Facing table and the missing NE pose are documented in `assets/ASSETS.md`.
- **Acceptance criteria:** Running the game shows sprites, not rectangles. Walk animation plays when moving, idle when not. Import settings committed. Smoke passes.
- **Dependencies:** T4.1 recommended (consistent scale), all Phase 3 actors exist.

### T4.3 Theme and 9-slice UI

- **Goal:** A single `Theme` uses the UI kit (panels, buttons, bars, slots, slider, tooltip styles as far as the kit goes).
- **Files / nodes:** `ui/theme/game_theme.tres` using `res://assets/ui/components/` — `panel_frame_small.png`, `panel_frame_large.png`, `button_normal.png` / `button_hover.png` / `button_pressed.png` / `button_disabled.png`, icons as needed. Apply the theme at the project or root-control level.
- **Implementation notes:** Use the **visually checked NinePatch margins** in `assets/ASSETS.md` (not ad-hoc guesses). Mid-edge gems on panels will smear if you resize a lot — keep controls near native size or overlay the gem. Colors: stone gray, deep purple, gold.
- **Acceptance criteria:** A small `ui` preview scene (or the level-up/death screens) uses the theme; no default gray Godot buttons on those screens. Import + smoke pass.
- **Dependencies:** UI kit assets available.

### T4.4 Main menu

- **Goal:** Boot goes to a main menu: **Play**, **Options** (stub until T5.3 if needed), **Quit**. Play starts a fresh run.
- **Files / nodes:** `ui/main_menu/main_menu.tscn`; set as the boot/main scene; `main` / arena is entered from Play. Layout reference: `assets/ui/mockups/main_menu_reference.png`. You may use that PNG as a **backdrop** only if you cover or omit the baked-in logo and buttons — do not ship two overlapping menus. Prefer building buttons with `button_*.png` and the Theme from T4.3. Working title is still a placeholder until the human confirms it.
- **Implementation notes:** Keyboard + mouse. Quit uses `get_tree().quit()`. Do not add settings sliders unless T5.3 is done in the same phase later — a disabled Options button is OK. Gold chip: `bar_gold.png`.
- **Acceptance criteria:** Headless boot still works (menu scene must not block quit-after). Manual: Play starts the arena with reset `RunState`; Quit exits the editor-run / exported build.
- **Dependencies:** T2.7, T4.3.

### T4.5 Level-up card UI

- **Goal:** The three-card choice uses the designed cards (icon, title, short description, reroll/skip).
- **Files / nodes:** Restyle `ui/level_up/` to follow `assets/ui/mockups/level_up_reference.png`. Use `panel_frame_*.png` / card panels, `button_normal.png` (and hover/pressed) for Reroll / Skip, and the gold/purple slot icons in `assets/ui/components/icon_*.png` (whip/weapon/passives as available — e.g. sword, staff, potion, flame).
- **Implementation notes:** Do not change the rules, only presentation. Tooltips may use `tooltip_panel.png` (sample art is baked in — cover it with real text).
- **Acceptance criteria:** T2.3 / T2.4 tests still pass. Manual: cards are readable on the gothic panel and match the kit reasonably.
- **Dependencies:** T4.3, T3.3.

### T4.6 HUD and boss bar polish

- **Goal:** HP, XP, timer, gold use the kit’s bars; when the boss is alive, a boss bar appears (and hides on death).
- **Files / nodes:** Restyle `ui/hud/` with `bar_health.png` (or `_frame` + `_fill`), `bar_xp.png`, `bar_gold.png`, and the boss bar `bar_boss.png` (`assets/ASSETS.md` explains why the fill split is approximate). Reference layout: `assets/ui/mockups/gameplay_reference.png`. Boss bar listens to `boss_*` signals.
- **Implementation notes:** Keep HUD non-blocking and cheap to update (on signals, not heavy `_process` strings if avoidable). Pause / settings / close icons: `button_pause.png`, `button_settings.png`, `button_close.png`.
- **Acceptance criteria:** Existing HUD tests pass; ci for boss bar visibility on `boss_spawned` / hide on `boss_died`. Smoke passes.
- **Dependencies:** T4.3, T3.6, T2.6.

**Co si ověřit ručně**

- Hra po spuštění ukáže **gotické menu**, ne šedé výchozí ovládací prvky Godotu.
- V aréně vidíš **dlaždice, náhrobky / rekvizity a sprity** postav, ne barevné obdélníky (pokud nějaký sprit chybí, napiš agentovi / doplň podklad).
- Level-up karty vypadají jako návrh (tři karty, reroll, skip). HUD a boss bar jdou číst a pasují ke stylu (šedá, nachová, zlato).
- Pixel art **není rozmazaný** (nearest filter). Když něco nesedí velikostí (hrdina je obří proti dlaždici), zastav a řeš škálu, ne to ignoruj.

---

## Phase 5 — Meta progression and save (3–4 weeks)

**Milestone / definition of done:** Gold from runs persists in `user://`. The player can unlock the two extra weapons (or a simple modifier) between runs. Options (at least fullscreen and volume) persist. A run summary shows time, level, gold, and cause of end.

### T5.1 Save/load gold and settings

- **Goal:** `SaveManager` writes and reads a small file with `ConfigFile` or `FileAccess`.
- **Files / nodes:** `scripts/autoload/save_manager.gd` as autoload `SaveManager`; schema documented in a comment (`gold`, later `unlocks`, `settings`).
- **Implementation notes:** Only `user://`. Never commit a save file. Invalid / missing file → defaults, no crash. Add gold from `RunState` into meta gold on run end.
- **Acceptance criteria:** Headless unit test: write a temp path or `user://` test file, reload, values match; corrupted file falls back safely; `RunState.reset()` does not wipe meta gold. Smoke passes.
- **Dependencies:** T3.8, T2.7.

### T5.2 Meta unlocks

- **Goal:** A simple between-run screen (from the menu or a “Prep” button): spend gold to unlock weapons 2 and 3 (or similar, **two unlocks max**). Unlocks persist.
- **Files / nodes:** `ui/meta/unlocks.tscn`; save keys for owned unlocks; starting loadout on Play uses unlocked + whip.
- **Implementation notes:** Whip is always owned. Prices are exported constants or a tiny Resource — ask the human if numbers feel wrong. No deep talent trees.
- **Acceptance criteria:** Test: with enough gold, purchase unlock A, save, “reload” manager, unlock is still owned and gold was deducted; cannot buy twice. Play starts with the weapon available to the level-up pool or pre-equipped only if that was the design (default: unlocked weapons may appear as level-up cards or be choosable at run start — **ask** which of the two).
- **Dependencies:** T5.1, T3.2, T4.4.

### T5.3 Options menu

- **Goal:** Fullscreen (or windowed) toggle, master volume, maybe SFX/BGM if audio already exists; values persist.
- **Files / nodes:** `ui/options/options_menu.tscn`; hooks from the main menu; `SaveManager` settings section.
- **Implementation notes:** Use `Window` mode APIs documented in 4.x (`Window.MODE_FULLSCREEN` / exclusive — check the pinned docs). Volume via `AudioServer` bus once buses exist (even a Master bus now).
- **Acceptance criteria:** Setting a value, quitting to menu, and loading again restores it (automated if possible). Invalid values clamp. Smoke + import pass.
- **Dependencies:** T5.1, T4.4.

### T5.4 Run summary

- **Goal:** Death and victory both show time survived, level, gold earned, and cause (`death` / `victory`). Then Retry or Menu.
- **Files / nodes:** Extend the death screen or `ui/summary/run_summary.tscn`.
- **Implementation notes:** Read-only stats from `RunState`. Do not add share/screenshot features.
- **Acceptance criteria:** Forced death and forced victory each show the expected cause and a non-zero time after a simulated run. Buttons work as in T2.7 / T4.4.
- **Dependencies:** T2.7, T3.6, T4.4.

**Co si ověřit ručně**

- Dojdi běh (nebo se nech zabít), získej mince, vypni hru, zapni znovu: **zlato je stále tam**.
- Za zlato odemkneš zbraň, restart editoru to **nezapomene**, a v dalším běhu je odměna dostupná.
- Nastavení (celá obrazovka, hlasitost) přežije restart. Shrnutí po smrti / vítězství ukazuje čas a úroveň a jde z něj do menu i na Retry.

---

## Phase 6 — Juice, audio, polish (3–4 weeks)

**Milestone / definition of done:** Hits read clearly (flash, optional knockback, small camera shake, damage numbers), basic SFX and one music loop exist, menus and game-over feel finished enough for itch.io, and a crowded run stays acceptable on a modest PC and in a Web export test.

### T6.1 Combat juice

- **Goal:** On hit: sprite flash, short knockback, optional tiny `Camera2D` shake, floating damage text (pooled).
- **Files / nodes:** `scripts/systems/hit_feedback.gd` or small helpers; `scenes/vfx/damage_number.tscn`; shake on the camera script.
- **Implementation notes:** Keep it subtle; expose intensities as exports. Damage numbers use the pool. No slow-motion systems.
- **Acceptance criteria:** Ci can call `apply_hit_feedback` without errors; a damage number appears and returns to the pool. Shake does not leave the camera offset permanently. Smoke passes.
- **Dependencies:** T3.7, T1.2, T1.6.

### T6.2 Sound effects

- **Goal:** SFX for hit, death, gem pickup, level-up, button click, player hurt, boss spawn — as far as assets exist.
- **Files / nodes:** `AudioManager` autoload; `assets/audio/sfx/`; buses. Missing sounds: skip or use a clearly temporary beep, listed in the changelog, **do not scrape copyrighted game audio**.
- **Implementation notes:** Ask the human about licensing / sources. One-shots via the manager, not ad-hoc `AudioStreamPlayer` trees in every enemy if a simple manager will do.
- **Acceptance criteria:** A headless run does not error when playing a stream (audio may be silent headless — no crash is the bar). Manual: clicks and hits make sound with volume from options.
- **Dependencies:** T5.3 recommended, T0.3.

### T6.3 Music

- **Goal:** One looping menu track and/or one run track, with a fade or clean switch.
- **Files / nodes:** `assets/audio/music/`; `AudioManager` play/stop. License in README or a `CREDITS.md`.
- **Implementation notes:** Same licensing rule as T6.2. Loop via import settings, not a hacky restart that gaps if the file already loops.
- **Acceptance criteria:** Manual: music starts on menu, changes or stays correctly in a run, respects volume / mute. Headless: no errors.
- **Dependencies:** T6.2.

### T6.4 Game-over / menu polish

- **Goal:** Transitions are clean (no leftover pause, no stuck boss bar, no overlapping UI). Focus/hover on buttons looks intentional.
- **Files / nodes:** Fixes in existing UI scenes only; maybe a simple fade `ColorRect`.
- **Implementation notes:** Hunt pause leaks and `visible` bugs. This is a polish task, not a new feature.
- **Acceptance criteria:** Scripted sequence: menu → play → level-up → unpause → die → retry → die → menu, without `paused` stuck true at the menu and without errors in the log. Smoke passes.
- **Dependencies:** T4.4, T5.4.

### T6.5 Performance pass

- **Goal:** A “worst minute” (enemy cap, projectiles, gems) stays playable.
- **Files / nodes:** No new systems unless a profiler points to a concrete leak (forgotten `queue_free` outside the pool, per-frame string allocs on HUD, too many lights). Document the enemy cap.
- **Implementation notes:** Use the editor profiler locally; the agent can also add a ci “spawn cap” scene that runs headless for a few seconds. Web export constraints: Compatibility renderer already chosen in T0.3.
- **Acceptance criteria:** Headless stress scene at the documented cap exits 0. Manual: human plays a busy minute and reports FPS feel. If below acceptable, lower cap or fix allocations — do not add a new engine feature.
- **Dependencies:** T3.7, T3.5.

**Co si ověřit ručně**

- Zásahy jsou **čitelné** (záblesk, číslo poškození), ale ne tak divoké, aby z toho bolely oči nebo ujížděla kamera.
- Kliknutí v menu, úder, sebrání XP a smrt mají **zvuk**; hudba hraje a hlasitost v opcích funguje.
- Několikrát: menu → hra → level-up → smrt → retry → menu. Nic nezůstane **pauznuté** nebo s duplicitním HUD.
- V husté vlně si všimni FPS (i přibližně). Když to „sekačka“, napiš to před vydáním.

---

## Phase 7 — Release on itch.io (2–3 weeks)

**Milestone / definition of done:** A playable Windows build and a Web (HTML5) build exist from documented export presets, a short playtest pass has fixed blocker bugs, the itch.io page has a description, controls, credits, and both files (or a web embed), and the team has consciously decided whether to stay on 4.8-beta3 or move to a later RC/stable **before** the public post.

### T7.1 Export presets (Windows + Web)

- **Goal:** Reproducible exports.
- **Files / nodes:** Export presets in the project (commit presets **without** secrets); output goes to gitignored `export/`. Icons / name / company are placeholders until the human provides them.
- **Implementation notes:** Install official **4.8-beta3 export templates** matching the editor. Windows: standard desktop. Web: test in a browser; note SharedArrayBuffer / COOP-COEP / audio autoplay issues if they appear — document workarounds, do not invent flags. Compatibility renderer should help. Record the exact export commands or editor steps in `README.md`.
- **Acceptance criteria:** Both presets export without errors on the pinned toolchain. The Windows binary launches to the menu. The Web build loads a first screen in a local server test. Headless import still passes.
- **Dependencies:** T4.4, T6.4, T0.1 (matching templates).

### T7.2 Playtest and bugfix pass

- **Goal:** One focused pass on a full run (death and, if possible, boss). Fix blockers only (softlocks, save corruption, broken unlocks, unplayable performance, missing input).
- **Files / nodes:** Bugfixes in place; list known non-blockers in this roadmap’s changelog or a `KNOWN_ISSUES.md`.
- **Implementation notes:** Do not start new features. If a bug requires a design choice, ask.
- **Acceptance criteria:** A written short playtest note (what was tried, what was fixed). Blockers from that note are closed or explicitly deferred by the human.
- **Dependencies:** T7.1 recommended so the playtest includes an exported build, not only F5 from the editor.

### T7.3 itch.io package and page copy

- **Goal:** The human has everything needed to post: builds, screenshots list, draft text (title TBD), controls, credits, engine mention (Godot 4.8), and a short “beta engine” note if still not on stable.
- **Files / nodes:** `export/` artifacts (not necessarily in git); `CREDITS.md`; a `ITCH_PAGE.md` draft in English and/or Czech for the human to paste. **Do not publish** to itch.io as the agent — that is the human’s step unless they explicitly ask later.
- **Implementation notes:** Include how to play (WASD, auto-attack, level-up UI). No invented press quotes. Working title stays marked as such until confirmed.
- **Acceptance criteria:** `ITCH_PAGE.md` and `CREDITS.md` exist and list art / audio / font licenses honestly. README explains which file to upload for Windows vs Web.
- **Dependencies:** T7.2, T6.3 (credits).

### T7.4 Release checklist and engine-upgrade question

- **Goal:** Final checklist is ticked; ask the human whether to migrate off 4.8-beta3 if an RC or stable exists at release time.
- **Files / nodes:** Update this checklist and changelog; refresh `VERSION.txt` only if a migration was **approved** and done.
- **Implementation notes:** If staying on beta, the itch page must say it is built with a beta engine. If migrating, do that in a dedicated task/commit and re-run T7.1–T7.2.
- **Acceptance criteria:** All intended v1 tasks are `[x]` or explicitly deferred. The engine question has an answer recorded in the changelog. Export still works.
- **Dependencies:** T7.3.

**Co si ověřit ručně**

- Spustíš **exportovaný** Windows build (ne jen F5 v editoru) a ideálně i **Web** verzi v prohlížeči: menu, jeden krátký běh, smrt, restart, zlato po restartu hry.
- Na stránce itch.io (až ji budeš zakládat ty) sedí ovládání, kredit, licence a upozornění, pokud jde stále o beta verzi Godotu.
- Rozhodni, jestli před zveřejněním **počkáš na 4.8 stable / RC**, nebo vydáš na pinuté betě. To není něco, co má agent udělat tiše.
- Pokud něco v exportu chybí (ikona, název hry, screenshoty), doplň podklady — agent je nemá vymýšlet za tebe.

---

## Changelog

The agent appends one bullet per finished task, newest first.

Format: ``- YYYY-MM-DD — T0.1 — short description of what landed``.

- 2026-11-14 — T6.5 — Add headless performance stress CI test (test_perf_stress.gd) at 35-enemy cap verifying bounded pooling over 240 physics frames
- 2026-11-14 — T6.4 — Verify clean state resets across full menu -> play -> level_up -> boss -> death -> retry -> menu flow (fix AudioManager signal signatures, add test_transitions.gd)
- 2026-11-14 — T6.3 — Add looping placeholder menu/run music tracks in AudioManager (respecting Master bus, switched via MainMenu and EventBus.run_started) and music CI checks
- 2026-11-14 — T6.2 — Add AudioManager autoload with pooled AudioStreamPlayer SFX (synthesized placeholder AudioStreamWAV tones for hit, death, gem, level_up, click, hurt, boss) and audio CI test
- 2026-11-14 — T6.1 — Add HitFeedback (sprite flash + pooled DamageNumber in PoolManager), enemy knockback, subtle Player Camera2D shake with decay, and combat juice CI test
- 2026-11-14 — T5.4 — Expand DeathScreen into full run summary (time, level, gold earned, death/victory cause) with MenuButton and updated death/victory CI assertions
- 2026-11-14 — T5.3 — Add OptionsMenu (ui/options/options_menu.tscn/.gd) with Fullscreen toggle and Master Volume slider persisted via SaveManager, wire into MainMenu, and add options CI test
- 2026-11-14 — T5.2 — Add UnlocksScreen (ui/meta/unlocks.tscn) for spending gold on Holy Bolt and Spirit Aura, filter LevelUpScreen pool by SaveManager.is_unlocked(), and add unlocks CI test
- 2026-11-14 — T5.1 — Add SaveManager autoload (ConfigFile in user:// for gold, unlocks, settings) with run gold banking and SaveManager CI test
- 2026-11-14 — T4.6 — Restyle Hud with gothic bar_health/bar_xp/bar_boss textures, bar_gold chip, and boss bar visibility/gold CI assertions
- 2026-11-14 — T4.5 — Restyle LevelUpScreen cards with 9-slice panel_frame_small, gothic icon slots, title/description labels, and themed Reroll/Skip buttons
- 2026-11-14 — T4.4 — Add gothic MainMenu (ui/main_menu/main_menu.tscn/.gd) as project boot scene with Play, disabled Options stub, Quit, gold chip, and CI test
- 2026-11-14 — T4.3 — Add game_theme.tres with 9-slice StyleBoxTextures (visually checked margins) and apply to LevelUpScreen & DeathScreen
- 2026-11-14 — T4.2 — Verify Player AnimatedSprite2D (4-dir idle/walk) and all 4 enemies + boss use concept sprites with bob/squash animations
- 2026-11-14 — T4.1 — Verify gothic isometric arena_tileset.tres (128x64 tileset_iso_blocks) and graveyard props in main.tscn with arena collision CI test
- 2026-11-14 — T3.8 — Add pooled ChickenPickup (heal + clamp) and CoinPickup (RunState.gold), enemy_died drop rolls in main.gd, and pickups CI test
- 2026-11-14 — T3.7 — Add PoolManager autoload for enemies, holy_bolt, and xp_gem with prefill on run_started and pooling stress CI test
- 2026-11-14 — T3.6 — Add BossVampireLord (10:00 spawn, boss bar in HUD, boss_spawned/boss_hp_changed/boss_died signals, victory summary on boss kill) and boss CI test
- 2026-11-14 — T3.5 — Add Skeleton, Zombie, and Ghost scenes/EnemyData resources, update WaveTable & Spawner for 4 MVP enemy types, and add CI test
- 2026-11-14 — T3.4 — Add EnemyData resource, bat.tres, data-driven EnemyBase.apply_data(), and enemy data CI test
- 2026-11-14 — T3.3 — Add PassiveData resource, 4 passive .tres upgrades, RunState.apply_passive(), LevelUpScreen integration, and passives CI test
- 2026-11-14 — T3.2 — Add HolyBolt (projectile) and SpiritAura (orbiting ring) weapons + .tres resources, wire into LevelUpScreen pool, and add CI hit test
- 2026-11-14 — T3.1 — Add WeaponData resource, whip.tres, WeaponController on Player, migrate WhipWeapon to WeaponData, and add weapon data CI test
- 2026-11-14 — T2.7 — Add DeathScreen (death_screen.tscn/.gd) pausing on player_died with Retry reset/reload, and death screen CI test
- 2026-11-14 — T2.6 — Track RunState.time_sec while unpaused in main.gd, add Hud (hud.tscn/.gd) for timer/HP/XP/level, and HUD CI test
- 2026-11-14 — T2.5 — Add WaveTable resource, early_waves.tres, and ring Spawner (spawner.tscn/.gd) clamped to arena bounds with live enemy cap + CI test
- 2026-11-14 — T2.4 — Add RunState.rerolls_left (3 per run), Reroll and Skip buttons on LevelUpScreen, and reroll/skip assertions in test_level_up.gd
- 2026-11-14 — T2.3 — Add LevelUpScreen (level_up_screen.tscn/.gd) pausing tree on level_up, showing 3 distinct upgrades, applying stat changes, and level-up CI test
- 2026-11-14 — T2.2 — Add xp_needed_for() and add_xp() with surplus carryover in RunState, EventBus.level_up signal, and XP curve CI test
- 2026-11-14 — T2.1 — Add XpGem pickup (xp_gem.tscn/.gd), drop on enemy_died via main.gd, emit xp_collected, and add XP gem CI test
- 2026-11-14 — T1.7 — Add enemy HP, take_damage, EventBus.enemy_died, queue_free on death, EnemyBat Hurtbox, and death CI test
- 2026-11-14 — T1.6 — Add WhipWeapon and WhipAttack auto-swinging on cooldown (player_hit) with whip CI test
- 2026-11-14 — T0.7 — Import sliced asset pack with Nearest filter, create 128x64 arena_tileset.tres, and upgrade Player/EnemyBat/Main to real sprites and graveyard props
- 2026-11-14 — T1.5 — Add Player Hurtbox, EnemyBat Hitbox, i-frames, RunState.hp sync, player_hurt/player_died signals, and contact damage CI test
- 2026-11-14 — T1.4 — Add EnemyBase and EnemyBat chasing player in main.tscn with chase CI test (default bat speed 95 vs player 180)
- 2026-11-14 — T1.3 — Expand isometric arena with WallLayer collision, Y-sorted PropBlock obstacles, and collision CI test
- 2026-11-14 — T1.2 — Add follow Camera2D with subtle smoothing to Player
- 2026-11-14 — T1.1 — Add Player CharacterBody2D with 2:1 isometric Y-foreshortened movement and movement CI test (question for Dominik: confirm movement feel)
- 2026-11-14 — T0.6 — Add empty isometric main scene (scenes/world/main.tscn) with Y-sort and 64x32 TileMapLayer
- 2026-11-14 — T0.5 — Add headless CI smoke test script (scripts/ci/smoke_test.gd) and document command in README.md
- 2026-11-14 — T0.4 — Add EventBus and RunState autoload stubs in project.godot
- 2026-11-14 — T0.3 — Create folder skeleton, project.godot defaults (Compatibility, 1280x720, typed warnings, Input Map, collision layers)
- 2026-11-14 — T0.2 — Add Godot 4 .gitignore and track AGENTS.md
- 2026-11-14 — T0.1 — Pin Godot 4.8-beta3 (4.8.beta3.official.c51ff06e8) in VERSION.txt and document engine setup in README.md
