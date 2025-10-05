extends Node2D

var pauseMenu = null
@onready var pauseMenuScene = preload("res://Scenes/PauseMenu.tscn")
@onready var ui_layer = $UILayer  

@onready var a_key_sprite = $AKey
@onready var d_key_sprite = $DKey
@onready var spacebar_sprite = $Spacebar

@export var a_green_texture : Texture2D
@export var d_green_texture : Texture2D
@export var space_green_texture : Texture2D
@export var next_scene_path: String = "res://Scenes/TutorialPart2.tscn"

var a_pressed = false
var d_pressed = false
var tutorial_done = false
var p_pressed = false
var o_pressed = false

@onready var checklist = preload("res://Scenes/ObjectiveCanvas.tscn").instantiate()

func _ready() -> void:
	$CharacterBody2D.play("idle")
	add_child(checklist)
	Global.current_checklist_type = "objective"
	$CharacterBody2D.fade_out_triggered.connect(_on_player_fade_out_triggered)
	var stream = $Background
	if stream is AudioStreamWAV:
		stream.set_loop(true)
		
	$Background.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	spacebar_sprite.visible = false
	pauseMenu = pauseMenuScene.instantiate()
	ui_layer.add_child(pauseMenu)  
	pauseMenu.visible = false

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
		#print("cancelled")
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

func _process(_delta: float) -> void:
	if $Background and not $Background.playing:
		$Background.play()
	
	if not a_pressed and Input.is_action_just_pressed("ui_left"):
		a_pressed = true
		a_key_sprite.texture = a_green_texture

	if not d_pressed and Input.is_action_just_pressed("ui_right"):
		d_pressed = true
		d_key_sprite.texture = d_green_texture

	# Once both are pressed, hide them and show spacebar
	if a_pressed and d_pressed and not tutorial_done:
		await get_tree().create_timer(0.5).timeout
		a_key_sprite.visible = false
		d_key_sprite.visible = false
		spacebar_sprite.visible = true
		
	if Input.is_action_just_pressed("ui_accept"):
		spacebar_sprite.texture = space_green_texture
		tutorial_done = true
		await get_tree().create_timer(0.5).timeout
		spacebar_sprite.visible = false
		
func _on_player_fade_out_triggered():
	var tutorial = get_tree().current_scene.get_node("TutorialCanvas")
	if is_instance_valid(tutorial):
		tutorial.cancel_tutorial()
	# Handle the fade + scene change here
	var fade_rect = $FadeLayer/FadeRect
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	get_tree().change_scene_to_file(next_scene_path)
