extends RigidBody2D

var player_in_range = false
var player: CharacterBody2D = null

func _ready():
	# Connect to your Area2D signal that detects the player nearby
	$Area2D.connect("player_in_range_changed", Callable(self, "_on_player_in_range_changed"))

func _on_player_in_range_changed(in_range: bool, body: Node):
	player_in_range = in_range
	player = body if in_range else null
