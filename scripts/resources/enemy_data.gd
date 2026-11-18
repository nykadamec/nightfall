class_name EnemyData
extends Resource
## Data-driven configuration for an enemy type.

@export var id: String = ""
@export var display_name: String = ""
@export var max_hp: int = 10
@export var move_speed: float = 95.0
@export var contact_damage: int = 10
@export var xp_value: int = 5
@export var enemy_scene: PackedScene
@export var chicken_drop_chance: float = 0.03
@export var coin_drop_chance: float = 0.12
