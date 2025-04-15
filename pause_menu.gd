extends Node2D

@onready var resumeButton = $Panel/ResumeButton
@onready var mainMenuButton = $Panel/MainMenuButton
@onready var restartLevelButton = $Panel/RestartLevelButton

# Called when the node enters the scene tree for the first time.
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
	get_tree().change_scene_to_file("res://main_menu.tscn")

func onRestartPressed():
	get_tree(). paused = false
	get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
