extends Area2D

# Signal that will be triggered when the player enters the death zone
signal boxPushed
signal player_died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Correct way to connect the signal
	connect("body_entered", Callable(self, "_on_body_entered"))

# Called when a body enters the death zone
func _on_body_entered(body):
	if body is CharacterBody2D:
		print("Player fell into the death zone!")
		# Trigger any restart behavior, like reloading the scene
		get_tree().reload_current_scene()  # This reloads the current scene
	if body is RigidBody2D:
		emit_signal("boxPushed")
