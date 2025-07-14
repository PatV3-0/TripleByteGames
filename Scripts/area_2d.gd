extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# Enable push on player
		body.can_push = true
		body.push_target = get_parent()  # The RigidBody2D
		
		# Enable pull on player
		body.can_pull = true
		body.pull_target = get_parent()

func _on_body_exited(body):
	if body.is_in_group("Player"):
		body.can_push = false
		body.push_target = null
		
		body.can_pull = false
		body.pull_target = null
