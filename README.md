# Nightfall (Working Title)

An isometric 2D survivor-like built in Godot.

## Engine

This project is pinned to **Godot 4.8-beta3** (standard GDScript build, **not** .NET).

- **Exact pinned version:** see [`VERSION.txt`](VERSION.txt) (`4.8.beta3.official.c51ff06e8`)
- **Official download:** [Godot 4.8-beta3 Archive](https://godotengine.org/download/archive/4.8-beta3/)
  - Download the **Standard** build for your OS (e.g. `macOS` arm64/x86_64, `Windows` x86_64, or `Linux`).
  - Do **not** add the Godot binary to git.

### Verifying your local binary

Make sure `godot` in your terminal matches `VERSION.txt`:

```sh
godot --version
```

> **Beta risk:** Godot 4.8-beta3 is pre-release software. Commit frequently, keep `.godot/` untracked, and do not upgrade or downgrade the engine mid-task.
