extends Area2D

@export var target_scene: PackedScene

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		body.grow_and_reduce_jump()
		if target_scene:
			call_deferred("_transition_to_target_scene", body)

func _transition_to_target_scene(player):
	var new_scene = target_scene.instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()

	await get_tree().create_timer(0.1).timeout

	var spawn_point = new_scene.get_node_or_null("PlayerSpawnPoint")
	if spawn_point:
		player.global_position = spawn_point.global_position
	else:
		player.global_position = Vector2.ZERO

	new_scene.add_child(player)
