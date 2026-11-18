extends SceneTree
## Headless CI test for T1.2: verifies main.tscn has an active Camera2D on Player.


func _initialize() -> void:
	var main_scene: PackedScene = load("res://scenes/world/main.tscn")
	if main_scene == null:
		push_error("Failed to load main.tscn")
		quit(1)
		return

	var main: Node = main_scene.instantiate()
	root.add_child(main)
	await process_frame

	var cam: Camera2D = root.get_camera_2d()
	if cam == null:
		push_error("No active Camera2D found in main.tscn")
		quit(1)
		return

	if not (cam.get_parent() is Player):
		push_error("Active Camera2D parent is not Player")
		quit(1)
		return

	print("TEST CAMERA PASSED")
	quit(0)
