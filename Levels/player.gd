extends CharacterBody2D

@export var speed : float = 150.0  # Player speed
@export var airborne : float = 0.6
@export var jump_force : float = 550.0  # Jump force
@export var gravity : float = 1200.0  # Gravity force

var pushModeActive: bool = false
var pullModeActive: bool = false
var facing_direction: int = -1
var object_being_pulled: RigidBody2D = null  # Track object being pulled

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update gravity and apply it to the velocity.y
	velocity.y += gravity * delta
	
	var currentSpeed = speed
	if not is_on_floor():
		currentSpeed *= airborne
		
	pushModeActive = Input.is_action_pressed("toggle_push")
	pullModeActive = Input.is_action_pressed("toggle_pull")

	if not pushModeActive and not pullModeActive:
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
			
	elif pullModeActive:
		# Pulling reduces speed but assumes something is being dragged behind
		if object_being_pulled:
			var pull_force = 150  # The strength of the pull force
			var direction = facing_direction  # Determine the direction based on the player's facing direction
			
			# Apply the pulling force to the object (make sure object_being_pulled is a RigidBody2D)
			object_being_pulled.apply_impulse(Vector2(direction * pull_force, 0), object_being_pulled.position)
			
			# Reduce the player's speed while pulling the object
			velocity.x = currentSpeed * 0.25  # Slower while pulling the object
			
		elif Input.is_action_pressed("ui_right"):
			velocity.x = -currentSpeed * 0.5
			facing_direction = 1
		elif Input.is_action_pressed("ui_left"):
			velocity.x = currentSpeed * 0.5
			facing_direction = -1
		else:
			velocity.x = 0

	# Move the player and apply gravity
	move_and_slide()

	# Jumping mechanic (only allow jumping when on the floor)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -jump_force  # Apply jump force

# Detect the object to be pulled (example: when colliding with a specific object)
func _on_pullable_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and body.name == "TissueBoxMain":  # Ensure it's a RigidBody2D object to be pulled
		object_being_pulled = body  # Store the object being pulled

# Detect when the player stops pulling (e.g., exiting the pullable area)
func _on_pullable_body_exited(body: Node2D) -> void:
	if body == object_being_pulled:
		object_being_pulled = null  # Stop pulling the object when it exits
