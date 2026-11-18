# Nightfall

An open-source **isometric 2D survivor-like** game and modular starter template built with **Godot 4.8-beta3** (pure GDScript, static typing enforced).

- **Website & Docs (GitHub Pages):** [`docs/index.html`](docs/index.html)
- **Code License:** [MIT](LICENSE)
- **Art Assets License:** [CC0 1.0 Public Domain](assets/LICENSE)

---

## Features

- **Playable Core Loop:** Main menu → procedural isometric graveyard arena → auto-attacking combat → XP gems & 3-card level-up draft (with reroll & skip) → Vampire Lord boss → death/victory summary → persistent gold & weapon unlocks.
- **Procedural Isometric Arena (`WorldGenerator`):** Seeded 128×64 diamond `TileMapLayer` terrain, boundary collision walls, Y-sorted gothic props, and flickering brazier lights.
- **Data-Driven Content:** Weapons (`WeaponData`), enemies (`EnemyData`), wave progression (`WaveTable`), and passives (`PassiveData`) live in `.tres` files under `resources/`.
- **Object Pooling (`PoolManager`):** Pre-warmed pools for enemies, projectiles, XP gems, coins, chickens, and floating damage numbers.
- **Meta-Progression & Audio:** Persistent `ConfigFile` saves (`SaveManager`) in `user://` and synthesized placeholder SFX/music (`AudioManager`).
- **Automated Headless CI:** 31 headless GDScript test suites under `scripts/ci/`.

---

## Controls

| Action | Input |
|---|---|
| Move | `W` `A` `S` `D` or Arrow Keys |
| Attack | Automatic on weapon cooldown |
| Select Upgrade / Menu | Mouse Click or `Enter` / `Space` |

---

## Engine Setup

This project is pinned to **Godot 4.8-beta3** (standard GDScript build, **not** .NET).

- **Exact pinned version:** see [`VERSION.txt`](VERSION.txt) (`4.8.beta3.official.c51ff06e8`)
- **Official download:** [Godot 4.8-beta3 Archive](https://godotengine.org/download/archive/4.8-beta3/)
  - Download the **Standard** build for your OS (`macOS`, `Windows`, or `Linux`).
  - Do **not** commit the Godot binary to git.

Verify your local binary matches `VERSION.txt`:

```sh
godot --version
```

> **Beta note:** Godot 4.8-beta3 is pre-release software. Keep `.godot/` untracked and commit regularly.

---

## Headless CI Checks

Run the asset import check, smoke test, and full headless test suite:

```sh
godot --headless --path . --import
godot --headless --path . -s res://scripts/ci/smoke_test.gd
for f in scripts/ci/*.gd; do godot --headless --path . -s "res://$f" || exit 1; done
```

---

## Reusing Nightfall as a Starter Template

You can freely fork or copy this repository to build your own survivor-like or isometric 2D game:

1. **Add a Weapon:** Create a new `WeaponData` `.tres` in `resources/weapons/`, attach a weapon scene, and register it in `scripts/ui/level_up_screen.gd`.
2. **Add an Enemy:** Create an `EnemyData` `.tres` in `resources/enemies/`, pair it with a scene extending `EnemyBase`, and add it to `resources/waves/early_waves.tres`. (Unused CC0 `werewolf.png` and `mushroom.png` sprites are already in `assets/characters/enemies/`.)
3. **Add a Passive:** Create a `PassiveData` `.tres` in `resources/upgrades/` and register it in `LevelUpScreen.PASSIVE_DATAS`.
4. **Swap Branding / Art:** Replace sprites in `assets/` (keep Nearest texture filtering enabled) and update `ui/main_menu/main_menu.tscn`.

See `AGENTS.md` and `ROADMAP.md` for detailed conventions, collision layers, and architecture notes.

---

## GitHub Pages Deployment

The static website lives in `docs/` (`docs/index.html`, `docs/css/style.css`, `docs/js/main.js`) with a `.gdignore` file so Godot skips it during import.

To publish via [GitHub Pages](https://docs.github.com/en/pages):

1. Push the repository to GitHub.
2. Open **Settings → Pages** in your GitHub repository.
3. Under **Build and deployment**, select either:
   - **GitHub Actions** (uses the included `.github/workflows/pages.yml`), or
   - **Deploy from a branch** → choose your branch (`main`) and folder **`/docs`**.

---

## Licensing

- **Code, scenes, resources, and website (`docs/`):** [MIT License](LICENSE)
- **Original art assets (`assets/`):** [CC0 1.0 Universal (Public Domain)](assets/LICENSE)
- **Third-party addons:**
  - `addons/lit/` — [MIT License](addons/lit/LICENSE)
  - `addons/godot_mcp_toolkit/` — [MIT License](addons/godot_mcp_toolkit/LICENSE)
