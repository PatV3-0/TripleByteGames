extends CharacterBody2D

#signal death_finished
signal fade_out_triggered
signal fade_back_triggered

@export var speed : float = 300.0
@export var jump_force : float = 400.0
@export var gravity : float = 1000.0
@export var air_control_multiplier : float = 1.0
@export var launch_strength: Vector2 = Vector2(0, -1000) # Upwards in 2D

var base_scale: Vector2
var base_speed: float
var base_jump_force: float
var base_acm: float
var jumping = false

var can_pull: bool = false
var pull_target: RigidBody2D = null
var pulling: bool = false
var pull_force = 200

var can_push: bool = false
var push_target: RigidBody2D = null
var pushing: bool = false
var push_force_magnitude = 1200

var size = 0 #regular and 1 for grown
var invincible: bool = false
var transforming: bool = false

@onready var jump_sound = $JumpSound
@onready var push_pull_sound = $PushPullSound
@onready var walking_sound = $Walking
@onready var fade_rect = $"../FadeLayer/FadeRect"
@onready var fade = $"../FadeLayer"
@onready var fade_zone = $"../FadeOut"
@onready var fade_back = $"../FadeOut2"
@onready var tutorial_ui = get_tree().get_current_scene().get_node_or_null("TutorialCanvas")

func _ready():
	#print(pull_target)
	Global.player_ref = self
	base_scale = scale
	base_jump_force = jump_force
	base_speed = speed
	base_acm = air_control_multiplier
	pulling = false
	pushing = false
	$Sprite2D.stop()
	$Sprite2D.play("idle")
	$Sprite2D.animation_finished.connect(_on_animation_finish)
	
	if fade_zone:
		fade_zone.body_entered.connect(_on_fade_out_body_entered)
	
	if fade_back:	
		fade_back.body_entered.connect(_on_fade_out_2_body_entered)
		
	if tutorial_ui:
		await get_tree().process_frame
		tutorial_ui.visible = true

func _physics_process(delta: float) -> void:
	#var pulling_now = false
	#var pushing_now = false
	if tutorial_ui:
		tutorial_ui.follow_player(global_position)

	velocity.y += gravity * delta
	var current_speed = speed
	if not is_on_floor():
		current_speed *= air_control_multiplier
	
	var moving_left = Input.is_action_pressed("ui_left")
	var moving_right = Input.is_action_pressed("ui_right")
	var jump_pressed = Input.is_action_just_pressed("ui_accept")
	var push_press = Input.is_action_pressed("toggle_push")
	var pull_press = Input.is_action_pressed("toggle_pull")

	if pull_press and can_pull and pull_target and not pulling and not jumping:
		#Begin Pulling
		pull_target.sleeping = false
		print(pull_target.position)
		var pull_vector = Vector2(global_position.x - pull_target.global_position.x, 0)
		var pull_distance = pull_vector.length()
		#Move Object
		if pull_distance > 0:
			var pull_dir = pull_vector.normalized()
			var pull_strength = clamp(pull_force * pull_distance, 0, 500) #Grasp It Firmly
			pull_target.apply_central_impulse(pull_dir * pull_strength)
		#Position Player	
		if moving_left:
			velocity.x = -speed * 0.6
		elif moving_right:
			velocity.x = speed * 0.6
		else:
			velocity.x = 0
		$Sprite2D.flip_h = pull_vector.x < 0
		#Play Animation
		if $Sprite2D.animation != "pull" && transforming == false:
			$Sprite2D.play("pull")
			if not push_pull_sound.playing:
				push_pull_sound.play()
		pulling = true
		$CollisionShape2D.scale.x = 0.5 * sign(pull_vector.x)
	elif pull_press and can_pull and pull_target and pulling and not jumping:
		#Recalculate Direction
		var pull_vector = Vector2(global_position.x - pull_target.global_position.x, 0)
		var pull_distance = pull_vector.length()
		#Move Object
		if pull_distance > 0:
			var pull_dir = pull_vector.normalized()
			var pull_strength = clamp(pull_force * pull_distance, 0, 500) #Grasp It Firmly
			pull_target.apply_central_impulse(pull_dir * pull_strength)
			
		if moving_left:
			velocity.x = -speed * 0.6
		elif moving_right:
			velocity.x = speed * 0.6
		else:
			velocity.x = 0
		$Sprite2D.flip_h = pull_vector.x < 0
	elif not pull_press and pulling:
		#Currently pulling but stopped pushing button
		pulling = false
		if $Sprite2D.animation == "pull" && transforming == false:
			$Sprite2D.stop()
		push_pull_sound.stop()
	elif push_press and can_push and push_target and not pushing and not jumping:
		#Get Object
		var push_vector = push_target.global_position - global_position
		var push_dir = sign(push_vector.x)
		
		if (moving_right and push_dir > 0) or (moving_left and push_dir < 0):
			velocity.x = push_dir * speed * 0.8
		else:
			velocity.x = 0
			
		var push_force_magnitude = 1200
		var push_force = Vector2(push_dir * push_force_magnitude, 0)
		push_target.apply_force(push_force, Vector2.ZERO)
		
		#Visual Offset
		var push_area = push_target.get_node_or_null("Area2D")
		var push_obj = push_target.get_node_or_null("CollisionShape2D")
		var push_sprite2 = push_obj.get_node_or_null("Sprite2D")
		var push_sprite = push_area.get_node_or_null("Sprite2D")
		if push_sprite:
			var skew_amount = 0.04
			var shift_amount = 6
			push_sprite.skew = skew_amount
			push_sprite2.skew = skew_amount
			push_sprite.offset.x = shift_amount * push_dir
			push_sprite2.offset.x = shift_amount * push_dir
	
		# Play Animation
		if $Sprite2D.animation != "push" && transforming == false:
			$Sprite2D.play("push")
			if not push_pull_sound.playing:
				push_pull_sound.play()
		
		pushing = true
			
	elif push_press and can_push and push_target and pushing and not jumping:
		# Continue pushing
		var push_vector = push_target.global_position - global_position
		var push_dir = sign(push_vector.x)
		
		if (moving_right and push_dir > 0) or (moving_left and push_dir < 0):
			velocity.x = push_dir * speed * 0.8
		else:
			velocity.x = 0
			
		
		var push_force = Vector2(push_dir * push_force_magnitude, 0)
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
			push_sprite.offset.x = shift_amount * push_dir
			push_sprite2.offset.x = shift_amount * push_dir
	
	elif not push_press and pushing:
		# Released push
		pushing = false
		if $Sprite2D.animation == "push":
			$Sprite2D.stop()
		push_pull_sound.stop()
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
		
	elif not pulling and not pushing:
		if moving_right:
			velocity.x = current_speed
			$Sprite2D.flip_h = true
			$CollisionShape2D.scale.x = 1
			if not jumping and $Sprite2D.animation != "walk" && transforming == false:
				$Sprite2D.play("walk")
		elif moving_left:
			velocity.x = -current_speed
			$Sprite2D.flip_h = false
			$CollisionShape2D.scale.x = -1
			if not jumping and $Sprite2D.animation != "walk" && transforming == false:
				$Sprite2D.play("walk")
		else:
			velocity.x = 0
			if not jumping and $Sprite2D.animation != "idle" && transforming == false:
				$Sprite2D.play("idle")

	# Jump input
	if jump_pressed and is_on_floor() and not pushing and not pulling:
		velocity.y = -jump_force
		jumping = true
		$Sprite2D.frame = 0  # Pre-jump
		if $Sprite2D.animation != "jump_start" && transforming == false:
			$Sprite2D.play("jump_start")
		#await get_tree().process_frame
		#$Sprite2D.frame = 1  # Push-off
		jump_sound.pitch_scale = randf_range(0.9, 1.1)
		jump_sound.play()

	move_and_slide()

	# Jump animation handling
	if jumping and not pushing and not pulling:
		if not is_on_floor():
			if velocity.y < -50:
				if $Sprite2D.animation != "jump_rise" && transforming == false:
					$Sprite2D.play("jump_rise")
			elif velocity.y > 50:
				if $Sprite2D.animation != "jump_fall" && transforming == false:
					$Sprite2D.play("jump_fall")
		else:
			if $Sprite2D.animation != "land" && transforming == false:
				$Sprite2D.play("land")
		
	##Sounds
	if is_on_floor() and not jumping and abs(velocity.x) > 0:
		if not walking_sound.playing:
			walking_sound.play()
	else:
		if walking_sound.playing:
			walking_sound.stop()
			
	
		
func _on_animation_finish():
	if $Sprite2D.animation == "land" && transforming == false:
		jumping = false
	if $Sprite2D.animation == "pull" && transforming == false:
		if pulling:
			$Sprite2D.play("pull")
		
	if $Sprite2D.animation == "push" && transforming == false:
		if pushing:
			$Sprite2D.play("push")
	
func grow(offset):
	if size == 1:
		return false
	size = 1
	transforming = true
	if "grow" in $Sprite2D.sprite_frames.get_animation_names():
		print("Growing")
		$Sprite2D.play("grow")
	else:
		$Sprite2D.play("idle")
	
	scale = base_scale * 1.5 
	jump_force = base_jump_force + 200 
	speed = base_speed -100
	air_control_multiplier = base_acm -0.4
	#update_camera_zoom()
	emit_signal("size_changed", size)
	await get_tree().create_timer(0.5).timeout
	transforming = false
	return true  # Successfully grew
	
func shrink(offset):		
	if size == 0:
		return false
	size = 0
	transforming = true
	if "shrink" in $Sprite2D.sprite_frames.get_animation_names():
		print("Shrinking")
		$Sprite2D.play("shrink")
	else:
		$Sprite2D.play("idle")
	
	scale = base_scale
	jump_force = base_jump_force
	speed = base_speed 
	air_control_multiplier = base_acm
	#update_camera_zoom()
	emit_signal("size_changed", size)
	await get_tree().create_timer(0.5).timeout
	transforming = false
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
		
func is_invincible() -> bool:
	return invincible
#func transition_to_next_scene(next_scene_path: String):
	#var fade_rect = $FadeLayer/FadeRect
	#var tween = create_tween()
	#tween.tween_property(fade_rect, "color:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	#await tween.finished
	#get_tree().change_scene_to_file(next_scene_path)

func _on_mushroom_launch_body_entered(body: Node2D) -> void:
	if size == 0:
		if body.is_in_group("Player"):
			print("Launch!")
			body.velocity = launch_strength

func _on_fade_out_2_body_entered(body: Node2D) -> void:
	print("Fade Back found")
	if body.is_in_group("Player"):
		print("Calling backwards")
		emit_signal("fade_back_triggered")
