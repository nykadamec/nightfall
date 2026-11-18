class_name WeaponData
extends Resource
## Data-driven configuration for a player weapon.

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var damage: int = 10
@export var cooldown: float = 1.2
@export var duration: float = 0.2
@export var attack_size: Vector2 = Vector2(110.0, 44.0)
@export var reach_offset: float = 64.0
@export var max_level: int = 5
@export var weapon_scene: PackedScene
