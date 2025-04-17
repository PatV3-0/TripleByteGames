extends Node2D

var pauseMenu = null
@onready var pauseMenuScene = preload("res://PauseMenu.tscn")
@onready var fadeRect = $UI/ColorRect
@onready var handle_block_scene = preload("res://Scripts/handle_block.tscn")
var handle_instance: Node2D
@onready var string_block_scene = preload("res://Scripts/string.tscn")
var string_instance: Node2D
@onready var falling_block: RigidBody2D = $Vent
@onready var wall_object: RigidBody2D = $Plug
var fadeDur = 0.7

func _ready() -> void:
	fadeRect.color = Color(0, 0, 0, 1)  # Fully transparent black
	fadeRect.visible = true
	fade_in_from_black()
	var player = $Player

	var camera = player.get_node("Camera2D")
	camera.offset = Vector2(0, 0)
	camera.zoom = Vector2(1, 1)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pauseMenu = pauseMenuScene.instantiate()
	$UI.add_child(pauseMenu)
	pauseMenu.visible = false

	# Place and add the handle block
	handle_instance = handle_block_scene.instantiate()
	handle_instance.position = Vector2(320, -20)
	add_child(handle_instance)

	# Set falling block and wall object references (these should already exist in the scene)
	falling_block.attached_object = wall_object

	# Place and add the string
	string_instance = string_block_scene.instantiate()
	string_instance.position = Vector2(340, -645)
	add_child(string_instance)

	# Connect string’s trigger to release the falling block
	if string_instance.has_method("connect"):
		string_instance.connect("string_pulled", _on_string_pulled)
		
func fade_in_from_black():
	fadeRect.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 0), fadeDur)
	tween.finished.connect(func():fadeRect.visible = false)

func _on_string_pulled():
	print("String pulled in tutorial level")
	falling_block.release()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if not pauseMenu.visible:
			showPauseMenu()
		else:
			hidePauseMenu()

func showPauseMenu():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pauseMenu.visible = true
	centerPauseMenu()

func hidePauseMenu():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pauseMenu.visible = false

func centerPauseMenu():
	var windowSize = get_viewport().size
	var pausePanel = pauseMenu.get_node("Panel")
	var pausePanelSize = pausePanel.size
	pausePanel.position = Vector2((windowSize.x - (pausePanelSize.x + 750)) / 2, (windowSize.y - (pausePanelSize.y + 300)) / 2)

func _process(delta: float) -> void:
	if pauseMenu.visible:
		centerPauseMenu()
		
func _physics_process(delta: float) -> void:
	var player = $Player
	
	if player.pushModeActive:
		var direction = player.facing_direction
		var player_position = player.position

		# Use the correct syntax for finding the box
		var box = null
		for body in $Player/PushArea.get_overlapping_bodies():
			if body.name == "Plug" or body.name == "Vent":
				box = body
				break

		if box and box is RigidBody2D:  # Ensure it's a RigidBody2D
			if abs(player.position.x - box.position.x) < 200:  # Adjust 20 for your threshold
				#print("Pushing...")
				# Apply impulse to the tissue box
				box.apply_impulse(Vector2(direction * 50, 0), box.position)  # Adjust strength
				box.angular_velocity = 0
			else:
				# If player is not pressing P, or not close enough to box, stop moving
				player.velocity.x = 0
				
	if player.pullModeActive:
		var direction = -player.facing_direction  # Opposite direction of push
		var player_position = player.position

		var box = null
		for body in $Player/PullArea.get_overlapping_bodies():
			if body.name == "Plug" or body.name == "Vent":
				box = body
				break

		if box and box is RigidBody2D:  # Ensure it's a RigidBody2D
			if abs(player.position.x - box.position.x) < 200:  # Adjust 20 for your threshold
				box.apply_impulse(Vector2(direction * 120, 0), box.position)  # Apply impulse instead of force
				box.angular_velocity = 0
			else:
				player.velocity.x = 0
				
func start_fade_to_black() -> void:
	fadeRect.visible = true 
	var tween = get_tree().create_tween()
	fadeRect.color = Color(0, 0, 0, 0)  # Fully transparent
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 1), fadeDur)
	tween.finished.connect(_on_fade_completed)

func _on_fade_completed() -> void:
	transition_to_next_scene()

func transition_to_next_scene():
	var player = $Player
	var player_position = player.global_position
	remove_child(player)
	var new_scene_packed = load("res://Scripts/BetweenScenes.tscn")
	var new_scene = new_scene_packed.instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.call_deferred("free")
	get_tree().current_scene = new_scene
	await get_tree().create_timer(0.1).timeout
	fadeRect.visible = false
	print("loaded")

	var new_player_spot = new_scene.get_node_or_null("PlayerSpawnPoint")
	if new_player_spot:
		player.global_position = new_player_spot.global_position
	else:
		player.global_position = Vector2(100, 100)

	new_scene.add_child(player)
	var camera = player.get_node("Camera2D")
	camera.offset = Vector2.ZERO
	camera.zoom = Vector2(1, 1)
