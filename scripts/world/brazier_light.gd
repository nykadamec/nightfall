class_name BrazierLight
extends PointLight2D
## Subtle warm torchlight flicker for graveyard braziers.

@export var base_energy: float = 1.15
@export var flicker_amplitude: float = 0.14
@export var flicker_speed: float = 7.5

var _time: float = 0.0


func _ready() -> void:
	_time = randf() * TAU


func _process(delta: float) -> void:
	_time += delta * flicker_speed
	energy = base_energy + sin(_time) * flicker_amplitude + sin(_time * 2.3) * (flicker_amplitude * 0.4)
