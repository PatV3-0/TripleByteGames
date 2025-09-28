extends Control

@onready var resumeButton = $PanelHolder/Panel/ResumeButton
@onready var mainMenuButton = $PanelHolder/Panel/MainMenuButton
@onready var restartLevelButton = $PanelHolder/Panel/RestartLevelButton
@onready var levelSelectPanel = $PanelHolder/LvlSelectPanel
@onready var buttons_container = $PanelHolder/LvlSelectPanel/VBoxContainer
@onready var invincibility_check = $PanelHolder/LvlSelectPanel/CheckButton
@onready var chef_check = $PanelHolder/LvlSelectPanel/CheckButton2

var levels = [
	"res://Scenes/tutorial_scene.tscn",
	"res://Scenes/TutorialPart2.tscn",
	"res://Scenes/Walls1.tscn",
	"res://Scenes/Walls2.tscn",
	"res://Scenes/KitchenCut.tscn",
	"res://Scenes/Kitchen1.tscn",
	"res://Scenes/Kitchen2.tscn",
	"res://Scenes/Kitchen3.tscn",
	"res://Scenes/Kitchen4.tscn",
	"res://Scenes/Garden1.tscn",
	"res://Scenes/Garden2.2.tscn",
	"res://Scenes/Underground1.tscn",
	"res://Scenes/Underground2.tscn",
	"res://Scenes/Stairs.tscn",
	"res://Scenes/BackInside.tscn",
	"res://Scenes/BackInside2.tscn",
	"res://Scenes/Final.tscn"
]
func _ready() -> void:	
	if resumeButton:
		resumeButton.pressed.connect(self._on_resume_pressed)
	if mainMenuButton:
		mainMenuButton.pressed.connect(self.onMainMenuPressed)
	if restartLevelButton:
		restartLevelButton.pressed.connect(self.onRestartPressed)
	invincibility_check.connect("toggled", Callable(self, "_on_invincibility_toggled"))
	chef_check.connect("toggled", Callable(self, "_on_chef_toggled"))
		
	for i in range(levels.size()):
		var btn = buttons_container.get_child(i)
		#btn.text = "Level " + str(i + 1)
		btn.connect("pressed", Callable(self, "_on_level_button_pressed").bind(i))

	levelSelectPanel.visible = false

func _on_resume_pressed():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.visible = false

func onMainMenuPressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func onRestartPressed():
	get_tree(). paused = false
	get_tree().reload_current_scene()
	
func _on_level_select_button_pressed():
	levelSelectPanel.visible = not levelSelectPanel.visible
	
func _on_level_button_pressed(level_index):
	get_tree().paused = false
	get_tree().change_scene_to_file(levels[level_index])
	
func _on_invincibility_toggled(button_pressed: bool):
	CheatManager.invincible = button_pressed
	print("Invincibility: ", CheatManager.invincible)
	
func _on_chef_toggled(button_pressed: bool):
	if button_pressed:
		Ingredients.collect_all_ingredients()
	else:
		Ingredients.reset_ingredients()
	print("Chef: ", button_pressed)
	
func _input(event):
	if event.is_action_pressed("CheatKey"):
		levelSelectPanel.visible = not levelSelectPanel.visible
		
func _process(_delta: float) -> void:
	pass
