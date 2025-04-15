extends Node2D

var pauseMenu = null
@onready var pauseMenuScene = preload("res://PauseMenu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var camera = $Player/Camera2D
	camera.offset.x = -2000
	slide_camera_to_offset(Vector2(100, 0), 10)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pauseMenu = pauseMenuScene.instantiate()
	$UI.add_child(pauseMenu)
	pauseMenu.visible = false
	
	$Area2D.connect("boxPushed", Callable(self, "onBoxFell"))
	$TissueBoxMain.connect("body_entered", Callable(self, "_on_TissueBox_body_entered"))

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
	pausePanel.position = Vector2((windowSize.x - (pausePanelSize.x + 750)) / 2, (windowSize.y - (pausePanelSize.y + 300)) / 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
				box.apply_force(Vector2(direction * 280, 0), box.position)  # Adjust strength
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
			ball.apply_impulse(Vector2(direction * 150, 0))
			
@warning_ignore("unused_parameter")
func show_instruction_and_pause(text: String, duration: float) -> void:
	$UI/InstructionLabel.text = text
	$UI/InstructionLabel.visible = true
	get_tree().paused = true  # Pause game logic
	await get_tree().create_timer(duration, true).timeout
	get_tree().paused = false
	$UI/InstructionLabel.visible = false
	
func slide_camera_to_offset(target_offset: Vector2, duration: float) -> void:
	var camera = $Player/Camera2D
	var start_offset = camera.offset
	var time = 0.0
	while time < duration:
		time += get_process_delta_time()
		var t = time / duration
		camera.offset = start_offset.lerp(target_offset, t)
		await get_tree().process_frame


func _on_instruction_1_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$UI/InstructionLabel.text = "Use the 'a' key to move left.\nAnd the 'd' key to move right."
		$UI/InstructionLabel.visible = true

func _on_instruction_1_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		$UI/InstructionLabel.visible = false

func _on_instruction_2_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		slide_camera_to_offset(Vector2(-100, 0), 1)
		show_instruction_and_pause("Press spacebar to jump", 2.0)

func _on_instruction_3_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		show_instruction_and_pause("Some jumps need to be timed a little more carefully...", 2.0)

func _on_instruction_4_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		show_instruction_and_pause("The pause menu has a nifty reset button to help you if you get stuck!\nPress esc to access the pause menu", 2.0)

func _on_instruction_5_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		show_instruction_and_pause("Some objects can be moved. Press and hold 'p' to push an object.", 2.0)
		
func _on_instruction_6_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		show_instruction_and_pause("Keep pushing!", 0)

func _on_instruction_7_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		show_instruction_and_pause("Now, let gravity do its thing...", 0)
