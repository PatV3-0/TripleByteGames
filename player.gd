extends CharacterBody2D

@export var speed : float = 300.0
@export var jump_force : float = 600.0
@export var gravity : float = 1200.0
@export var air_control_multiplier : float = 1.2  # Faster air control

var jumping = false
var grow_count = 0
const MAX_GROWTH = 7

var can_pull: bool = false
var pull_target: RigidBody2D = null
var pulling: bool = false

var can_push: bool = false
var push_target: RigidBody2D = null
var pushing: bool = false

func _ready():
	# Connect pull detection Area2D signals
	var pull_area = $"../Ground/PullBox/PullDetectionArea"
	pull_area.connect("player_in_range_changed", Callable(self, "_on_pullable_body_changed"))

	# Connect push detection Area2D signals
	var push_area = $"../Ground/CollisionShape2D9/Area2D"
	push_area.connect("player_in_range_changed", Callable(self, "_on_pushable_body_changed"))

func _on_pullable_body_changed(in_range: bool, body: Node):
	if body == self:
		can_pull = in_range
		pull_target = $"../Ground/PullBox" if in_range else null
		if not in_range and pulling:
			pulling = false
			$Sprite2D.stop()

func _on_pushable_body_changed(in_range: bool, body: Node):
	if body == self:
		can_push = in_range
		push_target = $"../Ground/CollisionShape2D9" if in_range else null
		if not in_range and pushing:
			pushing = false
			$Sprite2D.stop()

func _physics_process(delta: float) -> void:
	# Apply gravity
	velocity.y += gravity * delta

	var current_speed = speed
	if not is_on_floor():
		current_speed *= air_control_multiplier

	var moving_left = Input.is_action_pressed("ui_left")
	var moving_right = Input.is_action_pressed("ui_right")

	# Basic horizontal movement input if not pulling or pushing
	if not pulling and not pushing:
		if moving_right:
			velocity.x = current_speed
			$Sprite2D.flip_h = true
			$CollisionPolygon2D.scale.x = -0.5
		elif moving_left:
			velocity.x = -current_speed
			$Sprite2D.flip_h = false
			$CollisionPolygon2D.scale.x = 0.5
		else:
			velocity.x = 0

	# Jumping logic
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -jump_force
		jumping = true
		$Sprite2D.play("jump")
		$Sprite2D.frame = 0

	# Pulling logic (unchanged)
	if can_pull and pull_target and Input.is_action_pressed("toggle_pull"):
		var pull_distance = pull_target.global_position.distance_to(global_position)
		if pull_distance > 30:
			pulling = true
			pull_target.apply_central_impulse((global_position - pull_target.global_position).normalized() * 50)
		else:
			pulling = false
	else:
		if pulling:
			pulling = false
			$Sprite2D.stop()

	# Pushing logic
	var pushing_now = false
	if can_push and push_target and Input.is_action_pressed("toggle_push"):
		if moving_left or moving_right:
			pushing_now = true
			if not $Sprite2D.is_playing() or $Sprite2D.animation != "pushPull":
				$Sprite2D.play("pushPull")

			var direction = 1 if moving_right else -1
			
			# Set player velocity to push speed in that direction (move player)
			velocity.x = direction * current_speed * 0.8  # Slightly slower than normal speed

			# Apply a consistent force to the box in the same direction
			var push_force_magnitude = 5000  # Stronger force for smooth pushing
			var push_force = Vector2(direction * push_force_magnitude, 0)
			push_target.apply_central_impulse(push_force * delta)  # Impulse scaled by delta

			# Flip sprite properly
			$Sprite2D.flip_h = direction > 0
			$CollisionPolygon2D.scale.x = -0.5 if direction > 0 else 0.5

		else:
			pushing_now = false

	if pushing and not pushing_now:
		if $Sprite2D.is_playing() and $Sprite2D.animation == "pushPull":
			$Sprite2D.stop()

	pushing = pushing_now

	move_and_slide()

	# Handle jump animation frames
	if jumping:
		if not is_on_floor():
			$Sprite2D.frame = 1
		else:
			$Sprite2D.frame = 2
			jumping = false

	# Animation handling if not pulling or pushing
	if is_on_floor() and not jumping and not pulling and not pushing:
		if velocity.x != 0:
			$Sprite2D.play("walk")
		else:
			$Sprite2D.stop()


func grow(offset):
	if grow_count >= MAX_GROWTH:
		return

	scale *= 1.2
	jump_force += 100.0
	grow_count += 1
	update_camera_zoom(offset)

func update_camera_zoom(optional_offset := 105.0):
	var cam = $Camera2D
	if cam:
		var target_zoom = Vector2(1.0, 1.0) / (1.0 + 0.2 * grow_count)
		var tween = get_tree().create_tween()
		tween.tween_property(cam, "zoom", target_zoom, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
