extends CharacterBody2D

@export var speed : float = 300.0
@export var jump_force : float = 600.0
@export var gravity : float = 1200.0
@export var air_control_multiplier : float = 1.2  # Increase for faster air movement

var jumping = false
var grow_count = 0
const MAX_GROWTH = 7

var can_pull: bool = false
var pull_target: Node = null
var pulling: bool = false

func _ready():
	var detection_area = $"../Ground/PullBox/PullDetectionArea"
	detection_area.connect("player_in_range_changed", Callable(self, "_on_player_in_range_changed"))
	
func _on_player_in_range_changed(in_range: bool, player: Node):
	if player == self:
		can_pull = in_range
		pull_target = $"../Ground/PullBox" if in_range else null
		if not in_range and pulling:
			#print("Auto-stopping pull, player moved away")
			pulling = false

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
		var viewport_size = get_viewport_rect().size
		var tween = get_tree().create_tween()
		tween.tween_property(cam, "zoom", target_zoom, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
func freeze():
	velocity = Vector2.ZERO
	set_physics_process(false)
	set_process(false)

func _process(delta: float) -> void:
	velocity.y += gravity * delta
	
	var current_speed = speed
	if not is_on_floor():
		current_speed *= air_control_multiplier

	if not pulling:
		if Input.is_action_pressed("ui_right"):
			velocity.x = speed
			$Sprite2D.flip_h = true
			$CollisionPolygon2D.scale.x = -0.5
		elif Input.is_action_pressed("ui_left"):
			velocity.x = -speed
			$Sprite2D.flip_h = false
			$CollisionPolygon2D.scale.x = 0.5
		else:
			velocity.x = 0
	else:
		if Input.is_action_pressed("ui_right"):
			velocity.x = speed
			$CollisionPolygon2D.scale.x = -0.5
		elif Input.is_action_pressed("ui_left"):
			velocity.x = -speed
			$CollisionPolygon2D.scale.x = 0.5
		else:
			velocity.x = 0

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -jump_force
		jumping = true
		$Sprite2D.play("jump")
		$Sprite2D.frame = 0

	move_and_slide()

	if jumping:
		if not is_on_floor():
			$Sprite2D.frame = 1
		elif is_on_floor():
			$Sprite2D.frame = 2
			jumping = false

	if is_on_floor() and not jumping:
		if velocity.x != 0:
			$Sprite2D.play("walk")
		else:
			$Sprite2D.stop()

	if can_pull and pull_target and Input.is_action_pressed("toggle_pull"):
		#print("Pulling")
		pulling = true
		#var direction = pull_target.global_position.direction_to(global_position)
		var pull_distance = pull_target.global_position.distance_to(global_position)
		if pull_distance > 30:  # avoid jitter if too close
			#var pull_strength = 100 * delta  # tweak this value for speed
			pull_target.apply_central_impulse((global_position - pull_target.global_position).normalized() * 50)
	else:
		pulling = false

func _on_pullable_body_entered(body: Node2D) -> void:
	if body.name == "PullDetectionArea":
		can_pull = true
		pull_target = body.get_parent()
		#print("Player entered pull range:", pull_target.name)

func _on_pullable_body_exited(body: Node2D) -> void:
	pulling = false
	if body.name == "PullDetectionArea":
		can_pull = false
		pull_target = null
		if pulling:
			if velocity.x != 0:
				$Sprite2D.play("pushPull")
			else:
				$Sprite2D.stop()
			pulling = false
