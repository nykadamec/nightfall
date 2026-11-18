class_name PassiveData
extends Resource
## Data-driven passive upgrade. Stacking is additive per level (MAX_HP is flat; others are fractional).

enum StatType {
	MAX_HP,
	MOVE_SPEED,
	COOLDOWN_REDUCTION,
	DAMAGE,
}

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var stat_type: StatType = StatType.DAMAGE
@export var amount_per_level: float = 0.15
@export var max_level: int = 5
