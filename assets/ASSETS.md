# Asset pack — Nightfall (concept art, sliced)

České shrnutí: konceptové JPG textury jsou rozřezané na jednotlivé PNG ve `assets/` (dlaždice, rekvizity, hrdina ve 4 směrech, nepřátelé, předměty, UI). Dlaždice mají jednotnou izometrickou mřížku **128×64**. Zdroje jsou AI JPG, ne čistá pixel-art mřížka — v Godotu zapni **Filter: Nearest** a vypni mipmapy. **Žádné animační snímky neexistují**; v kódu použij lehký bob/squash tween jako zástupnou animaci. Náhled všeho je v `/workspace/godot-game/assets_preview.png`.

This file is the inventory and import guide for the coding agent. Do not overwrite PNGs under `assets/` except `.import` settings (see `AGENTS.md`).

## Source and processing

Concept sheets were 1024×1024 JPGs (mockups 1280×720) with dark gray / near-black backgrounds. Sprites were isolated by colour-distance keying, edge unmixing, and a light feather. Floor tiles and solid props had interior holes filled so dark cracks and soil were not keyed out. Original sheets live in `assets/_source/sheets/`; unscaled slices in `assets/_source/slices/`. The slicer is `_tools/slice_assets.py`.

**These are not a clean pixel grid.** Nearest-neighbour scaling was used wherever size changed. Expect slight JPEG fringe and uneven edges.

## Size conventions (in-game)

| Family | Rule | Notes |
|--------|------|--------|
| Floor tile top face | **128×64** (2:1 iso diamond) | Godot `TileSet` `tile_size` |
| Floor tile with sides (block) | 128×78–81 (atlas cell **128×81**) | Extra height is the extruded edge. Bottom-align the footprint to the grid. |
| Props (same sheet as tiles) | Scale **0.404** (128 / ~316.5) | Tree, fence, pillar, crate, etc. match the floor tiles. |
| Player + enemies + boss | Scale **0.566**, player height **112 px** | Shared scale for the character sheet. |
| Pickups | Gems/coin ~16–28 px tall, chicken 34, chest 46 | Drawn large on the sheet; scaled down so they stay smaller than the player. |
| UI | Native slice size (not downscaled) | Buttons ~161×84, panels 147×186 and 273×205, at a 1280×720 viewport. |

## Godot import settings (do this in T0.7)

1. **Project Settings → Rendering → Textures → Default Texture Filter = Nearest.**
2. **Mipmaps off** on every game sprite (Import dock, select the PNGs under `res://assets/`, uncheck mipmaps, **Reimport**). Prefer **Lossless** (or uncompressed) compression for these sprites.
3. **Fix Alpha Border** can stay on — it helps JPEG-edge fringes.
4. Do **not** import files under `assets/_source/` as in-game textures (JPGs have no alpha; they are provenance only).
5. Confirm in a test scene that tiles and the player look crisp, not blurry.

There are no `.import` files in this pack yet; Godot will create them on first open. Commit the `.import` files once the settings above are applied so everyone gets the same filter.

## TileSet setup (`tiles/`)

**Preferred atlas:** `tiles/tileset_iso_blocks.png` (768×81). Six tiles in one row, left to right:

`grass`, `cobblestone`, `dirt`, `graveyard_soil`, `water`, `lava`

**Flat variant:** `tiles/tileset_iso_flat.png` (768×64) — top face only, clean 128×64 diamonds. Use this if you do not want the thin extruded side. The block atlas is closer to the original art.

Individual PNGs with the same names also exist (`tile_grass.png`, `tile_grass_flat.png`, …).

### Steps in Godot 4.x

1. Create a new `TileSet` resource, e.g. `res://resources/tilesets/arena_tileset.tres`.
2. Tile Shape: **Isometric**. Tile Layout: **Diamond Down**. Tile Offset Axis: **Horizontal**.
3. **Tile Size: 128 × 64.**
4. Add an `Atlas Source` with texture `res://assets/tiles/tileset_iso_blocks.png`.
5. **Texture region size: 128 × 81** (block atlas). For the flat atlas, region size is 128 × 64 (equal to tile size).
6. Let Godot create the 6 tiles. Set physics polygons on walkable / solid tiles as needed (water and lava can be hurt or blocked later).
7. Because block textures are taller than 64 px, the extra 17 px is the side thickness. Adjust the atlas **texture origin** / tile rendering origin so the **footprint** (the 128×64 diamond) sits on the grid and the side hangs visually “down”. Enable **Y-sort** on the `TileMapLayer`.
8. `props/castle_ruins.png` is a **prop**, not a single atlas cell (a stone floor with ruined walls). Instance it as a Y-sorted scene, not as a 128×64 tile.

`tiles/TILESET.txt` repeats the numeric settings.

## NinePatch / StyleBoxTexture margins

Automatic margin detection was noisy; use these **visually checked** values. Panels and buttons have **gems / diamonds in the middle of each edge**, so a 9-slice will smear those ornaments if you resize a lot. Prefer near-native sizes, or overlay the gem as a child `TextureRect`.

| Texture | Native size | Suggested L, T, R, B | How to use |
|---------|-------------|----------------------|------------|
| `button_normal.png` (and hover / pressed / disabled) | 161×84–86 | **24, 28, 24, 28** | `StyleBoxTexture` on a `Button` / `Theme`. Keep width close to 161 if you want the top and bottom diamonds intact. |
| `panel_frame_small.png` | 147×186 | **36, 40, 36, 40** | Hollow frame (centre is already transparent). Mid-edge gems will stretch. |
| `panel_frame_large.png` | 273×205 | **36, 40, 36, 40** | Same as the small panel. |
| `tooltip_panel.png` | 303×176 | **36, 40, 36, 40** | Sample sword and placeholder dots are **baked in**. Use as a 9-slice frame and cover the sample art with real text, or crop the inner area. |
| `bar_gold.png` | 175×75 | **80, 16, 16, 16** | Left margin must clear the coin icon; stretch only the empty trough. |
| `bar_gem.png` | 174×74 | **80, 16, 16, 16** | Same idea, left gem icon. |

Square icon buttons (`button_pause`, `button_settings`, `button_close`, ~70×70) should **not** be 9-sliced — use them at native size.

### HUD bars

`bar_health.png`, `bar_xp.png`, `bar_boss.png` are the **full concept art** (already ~70–80 % filled). Also exported:

- `*_frame.png` — fill replaced with the empty-track colour
- `*_fill.png` — the visible fill only (not a full-length cap)

The frame/fill split is **approximate**: the concept bars are already partially filled and the fill edge is soft, so a little red can remain in `bar_health_frame.png`. For a clean meter, prefer a `TextureProgressBar` with the frame as under and a clipped fill, or a `ColorRect` / shader in the trough.

## Animations

**There are no animation frames** on the concept sheets (no walk cycle, no whip swing, no flap). Every character is a **static sprite**.

Placeholder motion (do this in code, do not invent frames):

- Idle: a 2–4 px vertical **bob** (`Tween` or a sine in `_process`)
- Hit: brief **squash** / flash
- Whip: a separate slash `Area2D` (see the gameplay mockup’s crescent) rather than animating the hand

Player directions (4 files):

| File | Direction |
|------|-----------|
| `characters/player/player_sw.png` | South-west / front-left, whip down-left |
| `characters/player/player_se.png` | South-east / front-right, whip to the right |
| `characters/player/player_n.png` | North / back |
| `characters/player/player_w.png` | West / a second front-left pose |

The sheet has **two left-facing front poses and no unique north-east view**. For NE, flip `player_n.png` or `player_se.png` (the cloak lining is slightly asymmetric — check the look). Switch textures from movement facing; no animated turn.

## Inventory (game-ready PNGs)

Paths are relative to `assets/`.

### tiles/ (14)

| File | Size | Use |
|------|------|-----|
| `tiles/tileset_iso_blocks.png` | 768×81 | **Main TileSet atlas**, 6 block tiles, 128×81 cells |
| `tiles/tileset_iso_flat.png` | 768×64 | Flat 128×64 diamond atlas, same order |
| `tiles/tile_grass.png` | 128×80 | Grass floor (block) |
| `tiles/tile_grass_flat.png` | 128×64 | Grass, flat diamond |
| `tiles/tile_cobblestone.png` | 128×79 | Cobblestone floor (block) |
| `tiles/tile_cobblestone_flat.png` | 128×64 | Cobblestone, flat |
| `tiles/tile_dirt.png` | 128×78 | Dirt floor (block) |
| `tiles/tile_dirt_flat.png` | 128×64 | Dirt, flat |
| `tiles/tile_graveyard_soil.png` | 128×81 | Graveyard soil with bones (block) |
| `tiles/tile_graveyard_soil_flat.png` | 128×64 | Graveyard soil, flat |
| `tiles/tile_water.png` | 128×81 | Purple bog / water (block) |
| `tiles/tile_water_flat.png` | 128×64 | Water, flat |
| `tiles/tile_lava.png` | 128×81 | Lava (block). Tiny nick possible on the right edge. |
| `tiles/tile_lava_flat.png` | 128×64 | Lava, flat |

### props/ (12)

| File | Size | Use |
|------|------|-----|
| `props/gravestones_group.png` | 108×87 | **Preferred** four-stone grave cluster (Y-sorted obstacle) |
| `props/gravestone_cross.png` | 35×42 | Cross only (from the cluster) |
| `props/gravestones_left_front.png` | 76×69 | Left + front stones (they were connected on the sheet) |
| `props/gravestone_right.png` | 44×50 | Right stone |
| `props/tree_dead.png` | 80×93 | Dead tree, Y-sorted; gaps between branches are transparent |
| `props/pillar.png` | 59×83 | Stone pillar |
| `props/crate.png` | 63×61 | Crate |
| `props/barrel.png` | 43×59 | Barrel |
| `props/brazier.png` | 51×75 | Lit brazier (static flame) |
| `props/fence.png` | 97×80 | Fence section; gaps between bars are transparent |
| `props/skull_pile.png` | 91×65 | Skull pile decoration |
| `props/castle_ruins.png` | 138×84 | Ruined castle floor + walls (prop, not a 128×64 tile) |

### characters/player/ (4)

| File | Size | Use |
|------|------|-----|
| `characters/player/player_sw.png` | 122×110 | Player SW |
| `characters/player/player_se.png` | 116×107 | Player SE |
| `characters/player/player_n.png` | 95×108 | Player back |
| `characters/player/player_w.png` | 138×109 | Player west / second left-facing pose |

### characters/enemies/ (7)

| File | Size | Use |
|------|------|-----|
| `characters/enemies/bat.png` | 129×80 | Bat (MVP) |
| `characters/enemies/skeleton.png` | 100×94 | Skeleton (MVP) |
| `characters/enemies/zombie.png` | 68×98 | Zombie (MVP) |
| `characters/enemies/ghost.png` | 64×107 | Ghost (MVP) |
| `characters/enemies/werewolf.png` | 101×98 | Werewolf (**v1 cut list**, sprite is ready) |
| `characters/enemies/mushroom.png` | 94×103 | Mushroom (**v1 cut list**, sprite is ready) |
| `characters/enemies/vampire_lord.png` | 184×163 | Vampire lord boss (MVP) |

### pickups/ (6)

| File | Size | Use |
|------|------|-----|
| `pickups/xp_gem_blue.png` | 18×28 | XP gem, common |
| `pickups/xp_gem_green.png` | 16×26 | XP gem, mid |
| `pickups/xp_gem_red.png` | 18×27 | XP gem, rare |
| `pickups/coin.png` | 23×28 | Gold coin |
| `pickups/chicken.png` | 39×34 | Heal pickup |
| `pickups/chest.png` | 55×46 | Chest (**v1 cut list**, sprite is ready) |

### ui/components/ (47)

**Buttons (4 states + 3 icon buttons):** `button_normal.png`, `button_hover.png`, `button_pressed.png`, `button_disabled.png` (the fourth sheet state is the unlit / disabled look — confirm in the menu), `button_pause.png`, `button_settings.png`, `button_close.png`.

**Panels:** `panel_frame_small.png`, `panel_frame_large.png`, `tooltip_panel.png`.

**Bars:** `bar_health.png` / `_frame` / `_fill`, `bar_xp.png` / `_frame` / `_fill`, `bar_boss.png` / `_frame` / `_fill`, `bar_gold.png`, `bar_gem.png`.

**Toggles & slider:** `checkbox_off.png`, `checkbox_on.png`, `checkbox_on_plain.png`, `toggle_off.png`, `toggle_on.png`, `toggle_on_wide.png`, `toggle_off_alt.png`, `slider.png`, `slider_knob.png` (knob cropped from the track; may include a sliver of track).

**Gold-slot weapon icons:** `icon_sword.png`, `icon_mace.png`, `icon_axe.png`, `icon_bow.png`, `icon_book.png`, `icon_sword_alt.png`, `icon_spear.png`, `icon_staff.png`, `icon_scythe.png`.

**Purple-slot upgrade icons:** `icon_shield.png`, `icon_ring.png`, `icon_sun.png`, `icon_flame.png`, `icon_bat.png`, `icon_potion.png`, `icon_skull.png`, `icon_swirl.png`.

### ui/mockups/ (3) — reference only

| File | Size | Use |
|------|------|-----|
| `ui/mockups/main_menu_reference.png` | 1280×720 | Menu composition / backdrop **reference**. The Nightfall logo, five buttons and the gold counter are already painted in — this is not a widget atlas. |
| `ui/mockups/level_up_reference.png` | 1280×720 | 3-card level-up layout and typography reference. |
| `ui/mockups/gameplay_reference.png` | 1280×720 | Arena and HUD layout reference. |

## Known weak results

- **AI JPG source:** not a true pixel grid; slight fringe and uneven silhouettes everywhere.
- **`tile_lava.png`:** a small bite may appear on the right edge of the diamond.
- **Flat tiles** are slightly softer than the block versions (top-face warp). Prefer `tileset_iso_blocks.png` unless you need a perfectly flat 64 px height.
- **`bar_health_frame.png`:** leftover reddish smear in the trough (see HUD bars above). Use the full `bar_health.png` as a mock, or accept an approximate split.
- **Bar fills** are only as long as the already-drawn fill, not a complete cap.
- **`tooltip_panel.png`:** demo sword and dots are baked in.
- **`slider_knob.png`:** rough crop, may include track pixels.
- **Player directions:** no unique NE sprite.
- **Gravestone individuals** are messier than `gravestones_group.png` (left and front stones were a single connected blob).
- **Werewolf, mushroom, chest** are sliced but stay on the v1 cut list unless the human expands scope.

A labelled contact sheet of every game-ready PNG is:

`/workspace/godot-game/assets_preview.png`
