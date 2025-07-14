extends CharacterBody2D

#signal death_finished

@export var speed : float = 300.0
@export var jump_force : float = 600.0
@export var gravity : float = 1200.0
@export var air_control_multiplier : float = 1.2  # Faster air control

@onready var jump_sound = $JumpSound
@onready var push_pull_sound = $PushPullSound
@onready var walking_sound = $Walking
@onready var fade_rect = $"../FadeLayer/FadeRect"

var jumping = false
var in_air = false
var grow_count = 0
const MAX_GROWTH = 1

var can_pull: bool = false
var pull_target: RigidBody2D = null
var pulling: bool = false

var can_push: bool = false
var push_target: RigidBody2D = null
var pushing: bool = false

func _ready():
	#hello 
	print(".")

func freeze():
	set_physics_process(false)
	set_process(false)
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	var current_speed = speed
	if not is_on_floor():
		current_speed *= air_control_multiplier

	var moving_left = Input.is_action_pressed("ui_left")
	var moving_right = Input.is_action_pressed("ui_right")

	var should_play_walk_sound = is_on_floor() and not jumping and abs(velocity.x) > 0
	if should_play_walk_sound:
		if not walking_sound.playing:
			walking_sound.play()
	else:
		if walking_sound.playing:
			walking_sound.stop()

	if not pulling and not pushing:
		if moving_right:
			velocity.x = current_speed
			$Sprite2D.flip_h = true
			$Sprite2D.offset.x = 95
			$CollisionShape2D.scale.x = 1
		elif moving_left:
			velocity.x = -current_speed
			$Sprite2D.flip_h = false
			$Sprite2D.offset.x = -65
			$CollisionShape2D.scale.x = -1
		else:
			velocity.x = 0

	# Jump input
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		$Sprite2D.frame = 0  # Pre-jump
		await get_tree().process_frame
		velocity.y = -jump_force
		jumping = true
		in_air = true
		$Sprite2D.play("jump")
		$Sprite2D.frame = 1  # Push-off
		jump_sound.pitch_scale = randf_range(0.9, 1.1)
		jump_sound.play()

	# Pull logic
	var pulling_now = false
	if can_pull and pull_target and Input.is_action_pressed("toggle_pull"):
		if moving_left or moving_right:
			pulling_now = true
			var direction = 1 if moving_right else -1
			velocity.x = direction * current_speed * 0.8
			if not $Sprite2D.is_playing() or $Sprite2D.animation != "pushPull":
				$Sprite2D.play("pushPull")
				if not push_pull_sound.playing:
					push_pull_sound.play()

			$Sprite2D.flip_h = direction < 0
			$CollisionShape2D.scale.x = -0.5 if direction > 0 else 0.5
			var pull_direction = (global_position - pull_target.global_position).normalized()
			var pull_force_magnitude = 800
			pull_target.apply_central_impulse(pull_direction * pull_force_magnitude)
	else:
		pulling_now = false

	if pulling and not pulling_now:
		if $Sprite2D.is_playing() and $Sprite2D.animation == "pushPull":
			$Sprite2D.stop()
		push_pull_sound.stop()
	pulling = pulling_now

	# Push logic
	var pushing_now = false
	if can_push and push_target and Input.is_action_pressed("toggle_push"):
		if moving_left or moving_right:
			pushing_now = true

			# Only play once if it's not already playing
			if !$Sprite2D.is_playing() or $Sprite2D.animation != "pushPull":
				$Sprite2D.play("pushPull")
				if not push_pull_sound.playing:
					push_pull_sound.play()

			var direction = 1 if moving_right else -1
			velocity.x = direction * current_speed * 2  # this controls player speed
			var push_force_magnitude = 2200  # increase this for stronger object push
			var push_force = Vector2(direction * push_force_magnitude, 0)
			push_target.apply_force(push_force, Vector2.ZERO)
	else:
		pushing_now = false


	if pushing and not pushing_now:
		if $Sprite2D.is_playing() and $Sprite2D.animation == "pushPull":
			$Sprite2D.stop()
		push_pull_sound.stop()
	pushing = pushing_now

	move_and_slide()

	# Jump animation handling
	if jumping:
		if not is_on_floor():
			if velocity.y < -50:
				if $Sprite2D.animation != "jump_rise":
					$Sprite2D.play("jump_rise")
			elif velocity.y > 50:
				if $Sprite2D.animation != "jump_fall":
					$Sprite2D.play("jump_fall")
		else:
			if in_air:
				$Sprite2D.play("land")
				in_air = false
				jumping = false
	if is_on_floor() and not jumping and not pulling and not pushing:
		if velocity.x != 0:
			$Sprite2D.play("walk")
		else:
			$Sprite2D.stop()

func grow(offset):
	if grow_count >= MAX_GROWTH:
		return false  # Player cannot grow further
	
	scale *= 1.1
	jump_force += 270
	speed += 150
	grow_count += 1
	update_camera_zoom(offset)
	return true  # Successfully grew
	
func play_death():
	if $Sprite2D and "death" in $Sprite2D.sprite_frames.get_animation_names():
		$Sprite2D.play("death")
		$Sprite2D.animation_finished.connect(_on_death_animation_finished, CONNECT_ONE_SHOT)
		set_physics_process(false)
	else:
		await get_tree().create_timer(1.0).timeout
		_on_death_animation_finished()
		
func _on_death_animation_finished():
	emit_signal("death_finished")

func update_camera_zoom(optional_offset := 105.0):
	print(optional_offset)
	var cam = $Camera2D
	if cam:
		var target_zoom = Vector2(1.0, 1.0) / (1.0 + 0.2 * grow_count)
		var tween = get_tree().create_tween()
		tween.tween_property(cam, "zoom", target_zoom, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_fade_out_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		transition_to_next_scene("res://Scenes/TutorialPart2.tscn")
		

func transition_to_next_scene(next_scene_path: String):
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	get_tree().change_scene_to_file(next_scene_path)
