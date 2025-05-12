extends CharacterBody2D

@export var speed : float = 150.0  # Player speed
@export var airborne : float = 0.6
@export var jump_force : float = 550.0  # Jump force
@export var gravity : float = 1200.0  # Gravity force
var previous_facing_direction: int = -1  # Start with same default as facing_direction

var pushModeActive: bool = false
var pullModeActive: bool = false
var facing_direction: int = -1
var object_being_pulled: RigidBody2D = null  # Track object being pulled

func release_from_handle():
	velocity.y = 150  # Give a little downward boost
	set_physics_process(true)
	
func flip_collision_polygon(polygon: CollisionPolygon2D, horizontal: bool = true):
	var new_polygon := []
	for point in polygon.polygon:
		var flipped_point = point
		if horizontal:
			flipped_point.x *= -1
		else:
			flipped_point.y *= -1
		new_polygon.append(flipped_point)
	polygon.polygon = new_polygon

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Flip the sprite based on direction
	var sprite = $Sprite2D  # Change this path if your sprite is named differently
	sprite.flip_h = facing_direction > 0
	if facing_direction != previous_facing_direction:
		flip_collision_polygon($CollisionPolygon2D)
		if facing_direction == 1 and previous_facing_direction == -1:
			print($CollisionPolygon2D.position)
			$CollisionPolygon2D.position.x -= 10
			print($CollisionPolygon2D.position)
			
		if facing_direction == -1 and previous_facing_direction == 1:
			print($CollisionPolygon2D.position)
			$CollisionPolygon2D.position.x += 10
			print($CollisionPolygon2D.position)
		previous_facing_direction = facing_direction

	# Update gravity and apply it to the velocity.y
	velocity.y += gravity * delta
	
	var currentSpeed = speed
	if not is_on_floor():
		currentSpeed *= airborne
		
	pushModeActive = Input.is_action_pressed("toggle_push")
	pullModeActive = Input.is_action_pressed("toggle_pull")
	
	if pushModeActive and not $PushPullSound.playing:
		$PushPullSound.play()
	elif not pushModeActive and $PushPullSound.playing:
		$PushPullSound.stop()

	if pullModeActive and not $PushPullSound.playing:
		#print("Play pull")
		$PushPullSound.play()
	elif not pullModeActive and $PushPullSound.playing:
		$PushPullSound.stop()

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
			facing_direction = -1
		elif Input.is_action_pressed("ui_left"):
			velocity.x = currentSpeed * 0.5
			facing_direction = 1
		else:
			velocity.x = 0

	# Move the player and apply gravity
	move_and_slide()

	# Jumping mechanic (only allow jumping when on the floor)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -jump_force  # Apply jump force
		$JumpSound.pitch_scale = randf_range(0.9, 1.1)
		$JumpSound.play()

# Detect the object to be pulled (example: when colliding with a specific object)
func _on_pullable_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and body.name == "TissueBoxMain":  # Ensure it's a RigidBody2D object to be pulled
		object_being_pulled = body  # Store the object being pulled

# Detect when the player stops pulling (e.g., exiting the pullable area)
func _on_pullable_body_exited(body: Node2D) -> void:
	if body == object_being_pulled:
		object_being_pulled = null  # Stop pulling the object when it exits
