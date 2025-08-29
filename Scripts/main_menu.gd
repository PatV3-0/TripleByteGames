extends Control

@onready var startButton = $VBoxContainer/StartGameButton
@onready var quitButton = $VBoxContainer/ExitButton
@onready var settingsButton = $VBoxContainer/SettingsButton
@onready var aboutButton = $VBoxContainer/AboutButton
@onready var savesButton = $VBoxContainer/ContinueGameButton
var SaveManager = preload("res://Scripts/SaveManager.gd")

@onready var saveSlotsPanel = $SaveSlotsPanel
@onready var aboutPanel = $AboutPanel
@onready var settingsPanel = $SettingsPanel

@onready var musicPlayer = $BackgroundSound

# Called when the node enters the scene tree for the first time.
func _ready():
	$BackgroundSound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	# Button Logic
	startButton.pressed.connect(onStartButton)
	quitButton.pressed.connect(onExit)
	settingsButton.pressed.connect(onSettingsButton)
	aboutButton.pressed.connect(onAboutButton)
	savesButton.pressed.connect(loadSaveData)
	
	$SettingsPanel/BackButton.pressed.connect(onSettingsBack)
	$AboutPanel/BackButton.pressed.connect(onAboutBack)
	$SaveSlotsPanel/BackButton.pressed.connect(onSavesBack)
	
	saveSlotsPanel.hide()
	settingsPanel.hide()
	aboutPanel.hide()
	
func onStartButton():
	var tutorialScene = preload("res://Scenes/Cutscene1.tscn")
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
	saveSlotsPanel.show()
	var saveManager = SaveManager.new()
	var data = {
		"playerName": "Patt", 
		"lastUnlockedLevel": 1,
		"timestamp": Time.get_datetime_string_from_system()
	}
	saveManager.saveGame(1, data)
	var availableSaves = saveManager.getAvailableSaves()
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

func onSettingsButton():
	$VBoxContainer.hide()
	settingsPanel.show()

func onSettingsBack():
	settingsPanel.hide()
	$VBoxContainer.show()
	
func onSavesBack():
	saveSlotsPanel.hide()
	$VBoxContainer.show()

func toggleMusic():
	if musicPlayer.playing:
		musicPlayer.stop()
	else:
		musicPlayer.play()
		
func onAboutButton():
	$VBoxContainer.hide()
	aboutPanel.show()

func onAboutBack():
	aboutPanel.hide()
	$VBoxContainer.show()
