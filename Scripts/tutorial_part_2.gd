extends Node2D

var pauseMenu = null
@onready var pauseMenuScene = preload("res://Scenes/PauseMenu.tscn")
@onready var fade_rect = $"FadeLayer2/FadeRect"
@onready var ui_layer = $UILayer  

@export var p_green_texture : Texture2D
@export var o_green_texture : Texture2D

@onready var p_key_sprite = $PKey
@onready var o_key_sprite = $OKey

@export var w_green_texture: Texture2D
@onready var w_key_sprite = $WKey
var w_pressed = false

var tutorial_done = false
var p_pressed = false
var o_pressed = false
var hide_timer_started = false

func _ready() -> void:
	var stream = $Background
	if stream is AudioStreamWAV:
		stream.set_loop(true)

	$Background.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var tutorial_area = $Hole_Tut
	tutorial_area.connect("show_w_key", Callable(self, "_on_show_w_key"))
	pauseMenu = pauseMenuScene.instantiate()
	ui_layer.add_child(pauseMenu)  
	pauseMenu.visible = false
	
	if fade_rect:
		
		var tutorial = get_tree().current_scene.get_node("TutorialCanvas")
		if is_instance_valid(tutorial):
			tutorial.cancel_tutorial()
		fade_rect.color.a = 1.0
		var tween = get_tree().create_tween()
		tween.tween_property(fade_rect, "color:a", 0.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _input(event):
	if event.is_action_pressed("toggle_push") and not p_pressed:
		p_pressed = true
		if p_key_sprite and p_green_texture:
			p_key_sprite.texture = p_green_texture
		start_hide_timer()

	if event.is_action_pressed("toggle_pull") and not o_pressed:
		o_pressed = true
		if o_key_sprite and o_green_texture:
			o_key_sprite.texture = o_green_texture
		start_hide_timer()
		
	if event.is_action_pressed("enter_door") and not w_pressed:
		w_pressed = true
		if w_key_sprite and w_green_texture:
			w_key_sprite.texture = w_green_texture
		start_hide_timer()

func start_hide_timer():
	if not hide_timer_started:
		hide_timer_started = true
		await get_tree().create_timer(1.0).timeout
		if p_key_sprite:
			p_key_sprite.visible = false
		if o_key_sprite:
			o_key_sprite.visible = false
		if w_key_sprite:
			w_key_sprite.visible = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if not pauseMenu.visible:
			showPauseMenu()
		else:
			hidePauseMenu()

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

func _process(_delta: float) -> void:
	if $Background and not $Background.playing:
		$Background.play()

func _on_show_w_key():
	if w_key_sprite and w_green_texture:
		w_key_sprite.texture = w_green_texture
		w_key_sprite.visible = true
