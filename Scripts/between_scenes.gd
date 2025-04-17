extends Node2D

var pauseMenu = null
@onready var pauseMenuScene = preload("res://PauseMenu.tscn")
@onready var fadeRect = $Fade
var fadeDur = 0.7

func _ready() -> void:
	$Label.text = "Part I\nThe Walls"
	fadeRect.color = Color(0, 0, 0, 1)  # Fully transparent black
	fadeRect.visible = true
	fade_in_from_black()
	await get_tree().create_timer(6.5).timeout
	start_fade_to_black()
	
	
func fade_in_from_black():
	fadeRect.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 0), fadeDur)
	tween.finished.connect(func():fadeRect.visible = false)
	
func start_fade_to_black() -> void:
	print("triggering")
	fadeRect.visible = true 
	var tween = get_tree().create_tween()
	fadeRect.color = Color(0, 0, 0, 0)  # Fully transparent
	tween.tween_property(fadeRect, "color", Color(0, 0, 0, 1), fadeDur)
	tween.finished.connect(_on_fade_completed)

func _on_fade_completed() -> void:
	print("complete")
	transition_to_next_scene()

func transition_to_next_scene():
	print("transitioning...")
	var new_scene_packed = load("res://main_menu.tscn")
	var new_scene = new_scene_packed.instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.call_deferred("free")
	get_tree().current_scene = new_scene
	await get_tree().create_timer(0.1).timeout
	fadeRect.visible = false
	print("loaded")

func _process(delta: float) -> void:
	pass
