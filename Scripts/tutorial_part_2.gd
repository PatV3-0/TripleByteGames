extends Node2D

var pauseMenu = null
@onready var pauseMenuScene = preload("res://Scenes/PauseMenu.tscn")
@onready var ui_layer = $UILayer  

var a_pressed = false
var d_pressed = false
var tutorial_done = false
var p_pressed = false
var o_pressed = false

func _ready() -> void:
	var stream = $Background
	if stream is AudioStreamWAV:
		stream.set_loop(true)
		
	$Background.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
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
	var pausePanel = pauseMenu.get_node("PanelHolder")
	var pausePanelSize = pausePanel.size
	var offset = Vector2(-400,-300)
	var adj = windowSize + offset
	pausePanel.position = (adj - pausePanelSize) / 2
	print(pausePanel.position)

func _process(_delta: float) -> void:
	if $Background and not $Background.playing:
		$Background.play()


func _on_hole_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
