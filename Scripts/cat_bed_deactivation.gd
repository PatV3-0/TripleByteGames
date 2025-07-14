extends Area2D

@export var deactivate_group_name := "DeathZones"
@onready var shape = $CollisionPolygon2D

func _ready():
	collision_layer = 0
	collision_layer = 1
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is CharacterBody2D and body.is_on_floor():
		
		var death_zones = get_tree().get_nodes_in_group(deactivate_group_name)
		for dz in death_zones:
			dz.monitoring = false  # Turn off detection
			dz.visible = false
