extends Node2D

var pauseMenu = null
@onready var pauseMenuScene = preload("res://PauseMenu.tscn")
@onready var ui_layer = $UILayer  

@onready var a_key_sprite = $AKey
@onready var d_key_sprite = $DKey
@onready var spacebar_sprite = $Spacebar
@onready var p_key_sprite = $PKey
@onready var o_key_sprite = $OKey

@export var a_green_texture : Texture2D
@export var d_green_texture : Texture2D
@export var space_green_texture : Texture2D
@export var p_green_texture : Texture2D
@export var o_green_texture : Texture2D

var a_pressed = false
var d_pressed = false
var tutorial_done = false
var p_pressed = false
var o_pressed = false

func _ready() -> void:
	#var stream = $Background
	#if stream is AudioStreamWAV:
		#stream.set_loop(true)
		
	#$Background.play()
	# Start with spacebar hidden
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

func showPauseMenu():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pauseMenu.visible = true
	centerPauseMenu()

func hidePauseMenu():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pauseMenu.visible = false

func centerPauseMenu():
	var windowSize = Vector2(get_viewport().size)
	var pausePanel = pauseMenu.get_node("Panel2")
	var pausePanelSize = pausePanel.size
	var offset = Vector2(-400,-300)
	var adj = windowSize + offset
	pausePanel.position = (adj - pausePanelSize) / 2

func _process(_delta: float) -> void:
	#if $Background and not $Background.playing:
		#$Background.play()
	
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
		
	if not p_pressed and Input.is_action_just_pressed("toggle_push"):
		p_pressed = true
		p_key_sprite.texture = p_green_texture
		await get_tree().create_timer(0.5).timeout
		p_key_sprite.visible = false
		
	if not o_pressed and Input.is_action_just_pressed("toggle_pull"):
		o_pressed = true
		o_key_sprite.texture = o_green_texture
		await get_tree().create_timer(0.5).timeout
		o_key_sprite.visible = false
