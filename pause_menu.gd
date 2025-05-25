extends Node2D

@onready var resumeButton = $Panel2/Panel/ResumeButton
@onready var mainMenuButton = $Panel2/Panel/MainMenuButton
@onready var restartLevelButton = $Panel2/Panel/RestartLevelButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var panel = $Panel2

	panel.anchor_left = 0
	panel.anchor_top = 0
	panel.anchor_right = 0
	panel.anchor_bottom = 0

	panel.position = Vector2(600, 400)
	
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
func _process(_delta: float) -> void:
	pass
