extends Node
## Global signal bus. Holds typed signals only — no gameplay state.

signal run_started
signal run_ended(reason: String)
signal player_hurt(current_hp: int, max_hp: int)
signal player_died
signal enemy_died(death_position: Vector2, xp_value: int)
signal xp_collected(amount: int, total_xp: int)
signal level_up(new_level: int)
signal boss_spawned(boss_name: String, max_hp: int)
signal boss_hp_changed(current_hp: int, max_hp: int)
signal boss_died
signal gold_collected(amount: int, total_gold: int)
