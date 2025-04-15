extends CharacterBody2D

@export var speed : float = 150.0  # Player speed
@export var airborne : float = 0.6
@export var jump_force : float = 550.0  # Jump force
@export var gravity : float = 1200.0  # Gravity force

var pushModeActive: bool = false
var facing_direction: int = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update gravity and apply it to the velocity.y
	velocity.y += gravity * delta
	
	var currentSpeed = speed
	if not is_on_floor():
		currentSpeed *= airborne
		
	pushModeActive = Input.is_action_pressed("toggle_push")

	if not pushModeActive:
		# Check for player movement (left and right)
		if Input.is_action_pressed("ui_right"):
			velocity.x = currentSpeed
			facing_direction = 1
		elif Input.is_action_pressed("ui_left"):
			velocity.x = -currentSpeed 
			facing_direction = -1
		else:
			velocity.x = 0  # No horizontal movement
	
	if pushModeActive:
		# Check if the player is colliding with a wall or pushing a box
		if is_on_wall():
			velocity.x *= 0.5  # Reduce speed when colliding and pushing against wall
		elif Input.is_action_pressed("ui_right"):
			velocity.x = currentSpeed * 0.5
			facing_direction = 1
		elif Input.is_action_pressed("ui_left"):
			velocity.x = -currentSpeed * 0.5
			facing_direction = -1
		else:
			velocity.x = 0  # No horizontal movement

	# Move the player and apply gravity
	move_and_slide()

	# Jumping mechanic (only allow jumping when on the floor)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -jump_force  # Apply jump force
