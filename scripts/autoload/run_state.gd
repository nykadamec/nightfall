extends Node
## Holds transient state for the current run and resets cleanly on new runs.

const DEFAULT_MAX_HP: int = 100
const DEFAULT_LEVEL: int = 1

var time_sec: float = 0.0
var xp: int = 0
var level: int = DEFAULT_LEVEL
var hp: int = DEFAULT_MAX_HP
var max_hp: int = DEFAULT_MAX_HP
var gold: int = 0


func _ready() -> void:
	reset()


func reset() -> void:
	time_sec = 0.0
	xp = 0
	level = DEFAULT_LEVEL
	max_hp = DEFAULT_MAX_HP
	hp = max_hp
	gold = 0
