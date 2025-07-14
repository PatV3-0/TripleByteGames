extends Control

@onready var resumeButton = $PanelHolder/Panel/ResumeButton
@onready var mainMenuButton = $PanelHolder/Panel/MainMenuButton
@onready var restartLevelButton = $PanelHolder/Panel/RestartLevelButton

func _ready() -> void:	
	if resumeButton:
		resumeButton.pressed.connect(self._on_resume_pressed)
	if mainMenuButton:
		mainMenuButton.pressed.connect(self.onMainMenuPressed)
	if restartLevelButton:
		restartLevelButton.pressed.connect(self.onRestartPressed)

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

func _process(_delta: float) -> void:
	pass
