# Attach this to your Camera2D node
extends Camera2D

@export var fixed_vertical_position := 0.0  

func _process(delta):
	global_position.y = fixed_vertical_position
