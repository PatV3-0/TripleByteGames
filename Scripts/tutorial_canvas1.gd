extends CanvasLayer

@onready var background: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $TutLabel

var is_playing: bool = false
var skip_all_flag: bool = false
var skip_current_line_flag: bool = false
var tutorial_active: bool = false

var tutorial_lines := []
var current_line_index := 0
#var current_trigger: Node = null

func _ready():
	background.visible = true
	background.play("default")
	
func follow_player(player_pos: Vector2):
	var cam = get_viewport().get_camera_2d()
	if cam:
		var screen_center = get_viewport().get_visible_rect().size / 2
		var screen_pos = screen_center + (player_pos - cam.global_position)
		background.position = screen_pos + Vector2(5, 260)
		label.position = screen_pos + Vector2(-385, 225)

func start_lines(lines: Array, trigger_node: Node = null) -> void:
	if is_playing:
		skip_all_flag = true
	await get_tree().process_frame
	
	tutorial_lines = lines
	current_line_index = 0
	skip_all_flag = false
	is_playing = true
	tutorial_active = true
	
	show_tutorial()
	while tutorial_active and current_line_index < tutorial_lines.size():
		if skip_all_flag:
			break  # skip everything if interrupted
		var line = tutorial_lines[current_line_index]
		if not is_instance_valid(self) or not tutorial_active:
			return
		label.text = line[0]
		label.visible = true
		skip_current_line_flag = false
		
		var t = Timer.new()
		t.one_shot = true
		t.wait_time = line[1]
		add_child(t)
		t.start()
		while t.time_left > 0 and tutorial_active and not skip_current_line_flag and not skip_all_flag and is_instance_valid(self):
			await get_tree().process_frame
		t.queue_free()
		#await wait_or_skip(line[1])
		current_line_index += 1
	
	
	if is_instance_valid(self):
		label.text = ""
		label.visible = false
		hide_tutorial()
	is_playing = false
	skip_current_line_flag = false
	skip_all_flag = false
	tutorial_active = false
	
func wait_or_skip(duration: float) -> void:
	var timer = get_tree().create_timer(duration)
	while tutorial_active and timer.time_left > 0 and is_instance_valid(self):
		if skip_current_line_flag or skip_all_flag:
			break
		await get_tree().process_frame
		
func show_tutorial():
	if not is_instance_valid(self):
		return
	background.speed_scale = 2.5  # make animation 2.5x faster
	background.play("expand")
	await background.animation_finished
	if not skip_all_flag and is_instance_valid(self):
		background.play("hover")  # loop hover while text is visible
		label.visible = true

func _on_expand_finished():
	if is_playing and not skip_all_flag:
		background.play("hover")  # loop while text visible
		
func hide_tutorial():
	if not is_instance_valid(self):
		return
	if not skip_all_flag:  # don't retract if interrupted
		background.speed_scale = 2.5 
		background.play("retract")
		await background.animation_finished
	label.visible = false 

#func update_tutorial_text(new_text: String):
	## called when a new tutorial interrupts
	#label.text = new_text
	#label.visible = true
	
# Skip to next line
func next_line():
	skip_current_line_flag = true

func skip_all():
	skip_all_flag = true
	skip_current_line_flag = true
	if is_instance_valid(label):
		label.visible = false
	if is_instance_valid(background):
		background.stop()
		background.play("default")
	
func _unhandled_input(event):
	if event.is_action_pressed("skip_text"):
		next_line()

#Exit for Pause Menu
func cancel_tutorial():
	tutorial_active = false
	skip_all_flag = true
	skip_current_line_flag = true
	if is_instance_valid(label):
		label.visible = false
	if is_instance_valid(background):
		background.stop()
		background.play("default")
