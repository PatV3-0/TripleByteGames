extends Control

@onready var startButton = $VBoxContainer/StartGameButton
@onready var quitButton = $VBoxContainer/ExitButton
@onready var saveSlotsPanel = $SaveSlotsPanel
@onready var aboutPanel = $AboutPanel
var SaveManager = preload("res://Scripts/SaveManager.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer.custom_minimum_size = Vector2(500, 400)
	var windowSize = get_viewport().size
	#print(windowSize)
	$VBoxContainer.position = Vector2((windowSize.x - ($VBoxContainer.custom_minimum_size.x + 750))/2, (windowSize.y - ($VBoxContainer.custom_minimum_size.y + 210))/2)
	#print(Vector2((windowSize.x - $VBoxContainer.custom_minimum_size.x)/2, (windowSize.y - $VBoxContainer.custom_minimum_size.y)/2))
	startButton.pressed.connect(onStartButton)
	quitButton.pressed.connect(onExit)
	saveSlotsPanel.hide()
	aboutPanel.hide()
	
func onStartButton():
	var tutorialScene = preload("res://Levels/TutorialLevel.tscn")
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
func _process(delta: float) -> void:
	pass
