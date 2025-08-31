extends CharacterBody2D

#signal death_finished
signal fade_out_triggered
signal fade_back_triggered

@export var speed : float = 300.0
@export var jump_force : float = 600.0
@export var gravity : float = 1200.0
@export var air_control_multiplier : float = 1.0
@export var launch_strength: Vector2 = Vector2(0, -1000) # Upwards in 2D

@onready var jump_sound = $JumpSound
@onready var push_pull_sound = $PushPullSound
@onready var walking_sound = $Walking
@onready var fade_rect = $"../FadeLayer/FadeRect"
@onready var fade = $"../FadeLayer"
@onready var fade_zone = $"../FadeOut"
@onready var fade_back = $"../FadeOut2"
@onready var tutorial_ui = null

var jumping = false
var in_air = false
var grow_count = 0
var shrink_count = 0
const MAX_GROWTH = 3
const MAX_SHRINK = 3
var can_pull: bool = false
var pull_target: RigidBody2D = null
var pulling: bool = false
var can_push: bool = false
var push_target: RigidBody2D = null
var pushing: bool = false

func _ready():
	print(pull_target)
	if fade_zone:
		fade_zone.body_entered.connect(_on_fade_out_body_entered)
	
	if fade_back:	
		fade_back.body_entered.connect(_on_fade_out_2_body_entered)
	
	tutorial_ui = get_tree().get_current_scene().get_node_or_null("TutorialCanvas")
	if tutorial_ui == null:
		print("TutorialCanvas not found!")
	else:
		await get_tree().process_frame
		print(tutorial_ui)
		tutorial_ui.visible = true
		tutorial_ui.hide_tutorial_text()
		tutorial_ui.hide_tutorial()

func show_tutorial():
	tutorial_ui.show_tutorial()

func hide_tutorial():
	tutorial_ui.hide_tutorial()

func show_tutorial_text(text: String):
	tutorial_ui.show_tutorial_text(text)

func hide_tutorial_text():
	tutorial_ui.hide_tutorial_text()

func freeze():
	set_physics_process(false)
	set_process(false)
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	if tutorial_ui:
		tutorial_ui.follow_player(global_position)

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
			#$Sprite2D.offset.x = 95
			$CollisionShape2D.scale.x = 1
		elif moving_left:
			velocity.x = -current_speed
			$Sprite2D.flip_h = false
			#$Sprite2D.offset.x = -65
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
		pulling_now = true
		
		pull_target.sleeping = false
		print(pull_target.position)
		
		# Calculate direction vector from object to player
		var pull_vector = Vector2(global_position.x - pull_target.global_position.x, 0)
		var pull_distance = pull_vector.length()
		if pull_distance > 0:
			var pull_dir = pull_vector.normalized()
			var pull_strength = clamp(300 * pull_distance, 0, 500) # scale by distance but cap
			pull_target.apply_central_impulse(pull_dir * pull_strength)
		
		# Handle player input for possible movement while pulling
		var player_input = 0
		if moving_left:
			velocity.x = -current_speed * 0.6
		elif moving_right:
			velocity.x = current_speed * 0.6
		else:
			velocity.x = 0
		
		# Play pull animation and sound
		if $Sprite2D.animation != "pushPull":
			$Sprite2D.play("pushPull")
			if not push_pull_sound.playing:
				push_pull_sound.play()
				
		# Flip sprite and scale collision shape based on direction
		$Sprite2D.flip_h = pull_vector.x < 0
		$CollisionShape2D.scale.x = 0.5 * sign(pull_vector.x)
	else:
		pulling_now = false

	# Stop pull effects if pulling has just ended
	if pulling and not pulling_now:
		if $Sprite2D.animation == "pushPull":
			$Sprite2D.stop()
		push_pull_sound.stop()

	pulling = pulling_now

	# Push logic
	var pushing_now = false
	if can_push and push_target and Input.is_action_pressed("toggle_push"):
		pushing_now = true

		if !$Sprite2D.is_playing() or $Sprite2D.animation != "pushPull":
			$Sprite2D.play("pushPull")
			if not push_pull_sound.playing:
				push_pull_sound.play()

		var direction = 1 if moving_right else -1
		velocity.x = direction * current_speed * 0.8
		var push_force_magnitude = 1200
		var push_force = Vector2(direction * push_force_magnitude, 0)
		push_target.apply_force(push_force, Vector2.ZERO)

		var push_area = push_target.get_node_or_null("Area2D")
		var push_obj = push_target.get_node_or_null("CollisionShape2D")
		var push_sprite2 = push_obj.get_node_or_null("Sprite2D")
		var push_sprite = push_area.get_node_or_null("Sprite2D")
		if push_sprite:
			var skew_amount = 0.04
			var shift_amount = 6
			push_sprite.skew = skew_amount
			push_sprite2.skew = skew_amount
			push_sprite.offset.x = shift_amount * direction
			push_sprite2.offset.x = shift_amount * direction
	else:
		pushing_now = false
		if push_target:
			var push_area = push_target.get_node_or_null("Area2D")
			var push_obj = push_target.get_node_or_null("CollisionShape2D")
			var push_sprite2 = push_obj.get_node_or_null("Sprite2D")
			var push_sprite = push_area.get_node_or_null("Sprite2D")
			if push_sprite:
				push_sprite.skew = 0
				push_sprite2.skew = 0
				push_sprite.offset.x = 0
				push_sprite2.offset.x = 0
				
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
	update_camera_zoom()
	return true  # Successfully grew
	
func shrink(offset):
	print("Shrinking")
	if grow_count >= MAX_SHRINK:
		print("Max shrink reached")
		return false  # Player cannot grow further
	
	print("Smaller")
	scale *= 0.8
	jump_force = 330
	speed -= 150
	shrink_count += 1
	update_camera_zoom()
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

func update_camera_zoom():
	var cam = $Camera2D
	if cam:
		# Base zoom factor (1,1 is normal)
		var base_zoom = Vector2(1, 1)
		# If the player shrinks (scale < 1), we want the camera to zoom in (smaller zoom value)
		# If the player grows (scale > 1), the camera zooms out
		var target_zoom = base_zoom / scale  # scale is a Vector2; works for uniform scaling
		var tween = get_tree().create_tween()
		tween.tween_property(cam, "zoom", target_zoom, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_fade_out_body_entered(body: Node2D) -> void:
	print("Fade Out found")
	if body.is_in_group("Player"):
		print("Calling transition")
		emit_signal("fade_out_triggered")
		

func transition_to_next_scene(next_scene_path: String):
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	get_tree().change_scene_to_file(next_scene_path)

func _on_mushroom_launch_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Launch!")
		body.velocity = launch_strength

func _on_fade_out_2_body_entered(body: Node2D) -> void:
	print("Fade Back found")
	if body.is_in_group("Player"):
		print("Calling backwards")
		emit_signal("fade_back_triggered")
