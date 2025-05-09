extends Node2D

var shown_instructions := {}
var pauseMenu = null
@onready var pauseMenuScene = preload("res://PauseMenu.tscn")
@onready var fadeRect = $UI/ColorRect
var fadeDur = 0.7

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	$Background.play()
	fadeRect.color = Color(0, 0, 0, 1) 
	fadeRect.visible = true
	fade_in_from_black()
	var camera = $Player/Camera2D
	camera.offset.x = -2000
	camera.offset.y = -2000
	camera.zoom = Vector2(1.5,1.5)
	slide_camera_to_offset(Vector2(100, 30), 0.1)
	fade_in_from_black()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pauseMenu = pauseMenuScene.instantiate()
	$UI.add_child(pauseMenu)
	pauseMenu.visible = false
	
	$Area2D.connect("boxPushed", Callable(self, "onBoxFell"))
	$TissueBoxMain.connect("body_entered", Callable(self, "_on_TissueBox_body_entered"))
	$Broom.connect("body_entered", Callable(self, "_on_broom_body_entered"))
	$Player.flip_collision_polygon($Player/CollisionPolygon2D, true)  # Horizontal flip
	
	#transition_to_next_scene()

func fade_in_from_black():
	var fadeDuration = fadeDur * 3
	fadeRect.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 0), fadeDuration)
	tween.finished.connect(func():fadeRect.visible = false)
	
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
	# Get the size of the window (viewport)
	var windowSize = get_viewport().size
	var pausePanel = pauseMenu.get_node("Panel")
	var pausePanelSize = pausePanel.size
	pausePanel.position = Vector2((windowSize.x - (pausePanelSize.x + 400)) / 2, (windowSize.y - (pausePanelSize.y + 300)) / 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Background and not $Background.playing:
		$Background.play()
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
			if body.name == "TissueBoxMain":
				box = body
				break

		# Ensure player is near the box
		if box:
			#print("Box")
			# If the player is close to the box and trying to push
			if abs(player.position.x - box.position.x) < 200:  # Adjust 20 for your threshold
				#print("Pushing...")
				# Apply impulse to the tissue box
				box.apply_force(Vector2(direction * 350, 0), box.position)  # Adjust strength
				box.angular_velocity = 0
			else:
				# If player is not pressing P, or not close enough to box, stop moving
				player.velocity.x = 0
				
func onBoxFell():
	var camera = $Player/Camera2D
	camera.zoom = Vector2(0.6,0.6)
	camera.offset.x = -1200
	
func _on_TissueBox_body_entered(body):
	if body.name == "BallBody":
		var direction = -1
		var ball = $BallBody
		ball.angular_velocity = 0
		if ball and ball is RigidBody2D:
			ball.apply_impulse(Vector2(direction * 10, 0))
			
@warning_ignore("unused_parameter")
func show_instruction_once(id: String, text: String, pause_duration: float) -> void:
	if shown_instructions.has(id):
		$UI/InstructionLabel.text = text
		$UI/InstructionLabel.visible = true
		await get_tree().create_timer(pause_duration * 2).timeout
		$UI/InstructionLabel.visible = false
	else:
		shown_instructions[id] = true
		$UI/InstructionLabel.text = text
		$UI/InstructionLabel.visible = true
		get_tree().paused = true
		await get_tree().create_timer(pause_duration, true).timeout
		get_tree().paused = false
		await get_tree().create_timer(pause_duration).timeout
		$UI/InstructionLabel.visible = false

	
func slide_camera_to_offset(target_offset: Vector2, duration: float) -> void:
	var camera = $Player/Camera2D
	var start_offset = camera.offset
	var time = 0.0
	while time < duration:
		time += get_process_delta_time()
		var t = time / duration
		camera.offset = start_offset.lerp(target_offset, t)
		camera.zoom = Vector2(1,1)
		await get_tree().create_timer(0.0).timeout


func _on_instruction_1_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$UI/InstructionLabel.text = "Use the 'a' key to move left. And the 'd' key to move right."
		$UI/InstructionLabel.visible = true

func _on_instruction_1_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		$UI/InstructionLabel.visible = false

func _on_instruction_2_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		slide_camera_to_offset(Vector2(-100, 50), 1)
		show_instruction_once("instr_2", "Press spacebar to jump", 1.0)

func _on_instruction_3_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		show_instruction_once("instr_3", "Some jumps need to be timed a little more carefully...", 1.0)

func _on_instruction_4_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		show_instruction_once("instr_4", "The pause menu has a nifty reset button to help you if you get stuck!\nPress esc to access the pause menu", 1.0)

func _on_instruction_5_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		show_instruction_once("instr_5", "Some objects can be moved. Press and hold left click to push an object.", 1.0)
		
func _on_instruction_6_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		show_instruction_once("instr_6", "Keep pushing!", 0.5)

func _on_instruction_7_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		show_instruction_once("instr_7", "You can pull objects by clicking the right mouse button. This will be useful later...", 1.1)

func _on_broom_body_entered(body: Node2D) -> void:
	if body.name == "BallBody":
		lock_broomstick()
		stop_ball(body)
		deactivate_deathzone()
		
func deactivate_deathzone() -> void:
	$Area2D.call_deferred("set_monitoring", false)

func stop_ball(ball: RigidBody2D):
	ball.call_deferred("set_linear_velocity", Vector2.ZERO)
	ball.call_deferred("set_angular_velocity", 0)
	ball.call_deferred("set_physics_process", false)

func lock_broomstick():
	await get_tree().create_timer(6.5).timeout
	var broom = $Broom
	broom.call_deferred("set_linear_velocity", Vector2.ZERO)
	broom.call_deferred("set_angular_velocity", 0)
	broom.call_deferred("set_physics_process", false)

func transition_to_next_scene():
	var player = $Player
	var player_position = player.global_position
	remove_child(player)

	var new_scene_packed = load("res://TutorialPt2.tscn")
	var new_scene = new_scene_packed.instantiate()

	get_tree().root.add_child(new_scene)
	get_tree().current_scene.call_deferred("free")
	$Background.stop()
	get_tree().current_scene = new_scene

	await get_tree().create_timer(0.1).timeout
	fadeRect.visible = false
	print("loaded")

	var new_player_spot = new_scene.get_node_or_null("PlayerSpawnPoint")
	if new_player_spot:
		player.global_position = new_player_spot.global_position
	else:
		player.global_position = Vector2(-1909, -425)

	new_scene.add_child(player)
	var camera = player.get_node("Camera2D")
	camera.offset = Vector2.ZERO
	camera.zoom = Vector2(1, 1)

func _on_fade_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		pass_through_deathzone()
		start_fade_to_black()
		
func pass_through_deathzone() -> void:
	$Area2D.monitoring = false
	$Area2D.visible = false
	print("Player passed through the death zone!")

	# Start the fade to black effect
func start_fade_to_black() -> void:
	fadeRect.visible = true 
	var tween = get_tree().create_tween()
	tween.tween_property(fadeRect, "color:a", 1.0, fadeDur)
	tween.finished.connect(func(): _on_fade_completed())

func _on_fade_completed() -> void:
	print("Fade completed!")
	transition_to_next_scene()
