extends Control

@onready var resumeButton = $PanelHolder/Panel/ResumeButton
@onready var mainMenuButton = $PanelHolder/Panel/MainMenuButton
@onready var restartLevelButton = $PanelHolder/Panel/RestartLevelButton
@onready var levelSelectPanel = $PanelHolder/LvlSelectPanel
@onready var buttons_container = $PanelHolder/LvlSelectPanel/VBoxContainer
@onready var invincibility_check = $PanelHolder/LvlSelectPanel/CheckButton
@onready var chef_check = $PanelHolder/LvlSelectPanel/CheckButton2
@onready var size_option = $PanelHolder/LvlSelectPanel/OptionButton
@onready var ingredient_sprite = $IngredientSprite
@onready var objective_sprite = $ObjectiveSprite

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
	$Background.play()
	_update_sprite_for_checklist()
	if resumeButton:
		resumeButton.pressed.connect(self._on_resume_pressed)
	if mainMenuButton:
		mainMenuButton.pressed.connect(self.onMainMenuPressed)
	if restartLevelButton:
		restartLevelButton.pressed.connect(self.onRestartPressed)
	invincibility_check.connect("toggled", Callable(self, "_on_invincibility_toggled"))
	chef_check.connect("toggled", Callable(self, "_on_chef_toggled"))
	
	size_option.item_selected.connect(_on_size_selected)
	if Global.player_ref:
		Global.player_ref.connect("size_changed", Callable(self, "_auto_select_size"))

	call_deferred("_auto_select_size")
	
	for i in range(levels.size()):
		var btn = buttons_container.get_child(i)
		#btn.text = "Level " + str(i + 1)
		btn.connect("pressed", Callable(self, "_on_level_button_pressed").bind(i))

	levelSelectPanel.visible = false
	
func _update_sprite_for_checklist():
	match Global.current_checklist_type:
		"ingredient":
			ingredient_sprite.visible = true
			objective_sprite.visible = false
		"objective":
			ingredient_sprite.visible = false
			objective_sprite.visible = true
		_:
			ingredient_sprite.visible = false
			objective_sprite.visible = false
			
func _on_size_selected(index):
	if not Global.player_ref:
		return
	match index:
		0:
			Global.player_ref.grow(105)   # Normal
		1:
			Global.player_ref.shrink(-105) # Small

func _auto_select_size():
	if not Global.player_ref:
		return
	match Global.player_ref.size:
		0: size_option.select(0)
		1: size_option.select(1)
			
func _on_resume_pressed():
	$Background.stop()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.visible = false

func onMainMenuPressed():
	$Background.stop()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func onRestartPressed():
	$Background.stop()
	get_tree(). paused = false
	get_tree().reload_current_scene()
	
func _on_level_select_button_pressed():
	$Background.stop()
	levelSelectPanel.visible = not levelSelectPanel.visible
	
func _on_level_button_pressed(level_index):
	$Background.stop()
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
