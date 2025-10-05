extends Node2D

@export var next_scene_path: String = "res://Scenes/BackInside.tscn"
var pauseMenu = null
@onready var pauseMenuScene = preload("res://Scenes/PauseMenu.tscn")
@onready var checklist = preload("res://Scenes/IngredientsCanvas.tscn").instantiate()
@onready var ui_layer = $UILayer  
#@onready var portalSprite1 = $"Portal/Violet"
#@onready var portalSprite2 = $"Portal/Purple"
@export var beetle_scene: PackedScene
@export var min_spawn_interval: float = 2.0
@export var max_spawn_interval: float = 5.0
@export var min_beetles: int = 3
@export var max_beetles: int = 5
@export var spawn_area_top_left: Vector2 = Vector2(-230, -1090)
@export var spawn_area_bottom_right: Vector2 = Vector2(-660, -690)
#@export var spawn_offset: Vector2 = Vector2(-200, -400) 
@export var spawn_area_size: Vector2 = Vector2(300, 300) # size of spawn area
@export var spawn_area_offset: Vector2 = Vector2(0, 0) 
@onready var camera = $"Camera2D"

func _ready() -> void:
	$CharacterBody2D/Sprite2D.play("idle")
	$CharacterBody2D.grow(105)
	$CharacterBody2D.fade_out_triggered.connect(_on_player_fade_out_triggered)
	add_child(checklist)
	var stream = $Background
	if stream is AudioStreamWAV:
		stream.set_loop(true)
		
	var timer = Timer.new()
	timer.wait_time = randf_range(min_spawn_interval, max_spawn_interval)
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_spawn_beetle)

	#portalSprite1.play("Swirl")
	#portalSprite2.play("Swirl")
	$Background.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pauseMenu = pauseMenuScene.instantiate()
	ui_layer.add_child(pauseMenu)  
	pauseMenu.visible = false

func _process(delta: float) -> void:
	#pass
	if camera:
		var camera_top_left = camera.global_position - (get_viewport().size / 2) / camera.zoom
		spawn_area_top_left = camera_top_left + spawn_area_offset
		spawn_area_bottom_right = spawn_area_top_left + spawn_area_size
	if $Background and not $Background.playing:
		$Background.play()

func _on_player_fade_out_triggered():
	var tutorial = get_tree().current_scene.get_node("TutorialCanvas")
	if is_instance_valid(tutorial):
		tutorial.cancel_tutorial()
	print("Called Transition")
	var fade_rect = $FadeLayer/FadeRect
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	get_tree().change_scene_to_file(next_scene_path)	

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if not pauseMenu.visible:
			showPauseMenu()
		else:
			hidePauseMenu()

func _input(event):
	if event.is_action_pressed("i_tab"): #"i_tab" is mapped to Tab in Input Map
		checklist.visible = !checklist.visible
		
func showPauseMenu():
	var tutorial = get_tree().current_scene.get_node("TutorialCanvas")
	if is_instance_valid(tutorial):
		tutorial.cancel_tutorial()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pauseMenu.visible = true
	#centerPauseMenu()

func hidePauseMenu():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pauseMenu.visible = false

func centerPauseMenu():
	var windowSize = Vector2(get_viewport().size)
	var pausePanel = pauseMenu.get_node("PanelHolder")
	var pausePanelSize = pausePanel.size
	var offset = Vector2(-400,-300)
	var adj = windowSize + offset
	pausePanel.position = (adj - pausePanelSize) / 2
	#print(pausePanel.position)
	
func _spawn_beetle():
	var beetle_count = randi() % (max_beetles - min_beetles + 1) + min_beetles
	
	for i in beetle_count:
		var beetle = beetle_scene.instantiate()
		# Random position within defined area
		beetle.global_position = Vector2(
			randf_range(spawn_area_top_left.x, spawn_area_bottom_right.x),
			randf_range(spawn_area_top_left.y, spawn_area_bottom_right.y)
		)
		get_tree().current_scene.add_child(beetle)
		beetle.call_deferred("_start_rolling")
		
	# Randomize the next spawn interval
	var timer = get_node("Timer")
	if timer:
		timer.wait_time = randf_range(min_spawn_interval, max_spawn_interval)
