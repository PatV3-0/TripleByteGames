extends Node

# Put all your levels in an array
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

func _input(event):
	# Example: press 1, 2, 3 on the keyboard to switch
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_1:
				_load_level(0)
			KEY_2:
				_load_level(1)
			KEY_3:
				_load_level(2)

func _load_level(index: int):
	if index >= 0 and index < levels.size():
		get_tree().change_scene_to_file(levels[index])
