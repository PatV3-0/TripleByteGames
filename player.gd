extends CharacterBody2D

@export var speed : float = 300.0  # Player speed
@export var jump_force : float = 600.0  # Jump force
@export var gravity : float = 1200.0  # Gravity force

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update gravity and apply it to the velocity.y
	velocity.y += gravity * delta

	# Check for player movement (left and right)
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	else:
		velocity.x = 0  # No horizontal movement

	# Move the player and apply gravity
	move_and_slide()

	# Jumping mechanic (only allow jumping when on the floor)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor:
		velocity.y = -jump_force  # Apply jump force
