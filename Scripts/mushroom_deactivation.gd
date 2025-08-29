extends Area2D

@export var deactivate_group_name := "DeathZones"
@export var trigger_group_name := "Pushable" # Objects that can deactivate the death zone
@onready var shape = $CollisionPolygon2D

func _ready():
	collision_layer = 1
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	# Only trigger if the body is in the trigger group
	if body.is_in_group(trigger_group_name):
		print("Death zone deactivated by ", body.name)
		var death_zones = get_tree().get_nodes_in_group(deactivate_group_name)
		for dz in death_zones:
			dz.monitoring = false  # Turn off detection
			dz.visible = false
