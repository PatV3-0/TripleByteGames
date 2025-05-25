extends RigidBody2D

var player_in_range = false
var player: CharacterBody2D = null

func _ready():
	$Area2D.connect("player_in_range_changed", Callable(self, "_on_player_in_range_changed"))

func _on_player_in_range_changed(in_range: bool, body: Node):
	player_in_range = in_range
	player = body if in_range else null

func _physics_process(_delta: float) -> void:
	if player_in_range and Input.is_action_pressed("toggle_push"):
		#print("Pushing")
		# Push *away* from player
		var direction = 1 if player.global_position.x < global_position.x else -1
		apply_central_impulse(Vector2(direction * 100, 0))
