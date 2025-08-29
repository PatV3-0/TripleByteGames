extends Node2D

@export var next_scene_path: String = "res://Scenes/Underground2.tscn"
var pauseMenu = null
@onready var pauseMenuScene = preload("res://Scenes/PauseMenu.tscn")
@onready var ui_layer = $UILayer  
#@onready var portalSprite1 = $"Portal/Violet"
#@onready var portalSprite2 = $"Portal/Purple"

func _ready() -> void:
	$CharacterBody2D.fade_out_triggered.connect(_on_player_fade_out_triggered)
	var stream = $Background
	if stream is AudioStreamWAV:
		stream.set_loop(true)
		
	#portalSprite1.play("Swirl")
	#portalSprite2.play("Swirl")
	$Background.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pauseMenu = pauseMenuScene.instantiate()
	ui_layer.add_child(pauseMenu)  
	pauseMenu.visible = false

func _process(delta: float) -> void:
	pass
	if $Background and not $Background.playing:
		$Background.play()

func _on_player_fade_out_triggered():
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

func showPauseMenu():
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
	
