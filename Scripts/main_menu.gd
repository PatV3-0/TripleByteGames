extends Control

@onready var startButton = $VBoxContainer/StartGameButton
@onready var quitButton = $VBoxContainer/ExitButton
@onready var saveSlotsPanel = $SaveSlotsPanel
@onready var aboutPanel = $AboutPanel
var SaveManager = preload("res://Scripts/SaveManager.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	$BackgroundSound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$VBoxContainer.custom_minimum_size = Vector2(600, 800)
	
	var window_size = get_viewport().size
	var sprite_texture_size = $Background/Sprite2D.texture.get_size()

	# Scale the sprite to nearly fill the screen, maintaining aspect ratio
	var scale_x = window_size.x / sprite_texture_size.x
	var scale_y = window_size.y / sprite_texture_size.y
	var scale = min(scale_x, scale_y) * 2

	$Background/Sprite2D.scale = Vector2(scale, scale)
	$Background/Sprite2D.centered = true
	$Background/Sprite2D.position = window_size / 2
	
	var horizontal_offset = 40
	var vertical_offset = 200 
	$Background/Sprite2D.position = Vector2(window_size) / 2 + Vector2(horizontal_offset, vertical_offset)
	
	# Center the VBoxContainer on the Sprite2D
	$VBoxContainer.position = $Background/Sprite2D.position - Vector2(640, 600) / 2
	
	#Button Logic
	startButton.pressed.connect(onStartButton)
	quitButton.pressed.connect(onExit)
	saveSlotsPanel.hide()
	aboutPanel.hide()
	
func onStartButton():
	var tutorialScene = preload("res://Scenes/tutorial_scene.tscn")
	#temp load to pt2 of tutorial
	#var tutorialScene = preload("res://Levels/TutorialPt2.tscn")
	$BackgroundSound.stop()
	get_tree().change_scene_to_packed(tutorialScene)
	#saveSlotsPanel.show()
	
func onContinueButton():
	loadSaveData()
	
func onExit():
	get_tree().quit()
	
func loadSaveData():
	var saveManager = SaveManager.new()
	var data = {
		"playerName": "Patt", 
		"lastUnlockedLevel": 1,
		"timestamp": Time.get_datetime_string_from_system()
	}
	saveManager.saveGame(1, data)
	var availableSaves = saveManager.get_available_saves()
	if availableSaves.is_empty():
		print("No saves found")
	else:
		showLevelSelection(availableSaves)
		
func showLevelSelection(saves):
	print("Available saves:", saves)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if $BackgroundSound and not $BackgroundSound.playing:
		$BackgroundSound.play()
