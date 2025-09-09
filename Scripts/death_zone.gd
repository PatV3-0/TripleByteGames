extends Area2D

signal player_died

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if not monitoring:
		print("Not monitoring")
		return  # Death Zone is inactive, ignore
	if body is CharacterBody2D:
		print("Player fell into the death zone!")
		var tutorial = get_tree().current_scene.get_node("TutorialCanvas")
		if is_instance_valid(tutorial):
			tutorial.cancel_tutorial()
		if body.has_method("play_death"):
			body.play_death()
			# Wait for animation before reloading
		if body.has_signal("death_finished"):
			body.connect("death_finished", Callable(self, "_on_player_death_finished"), CONNECT_ONE_SHOT)
		else:
			get_tree().create_timer(0.2).timeout.connect(_on_player_death_finished, CONNECT_ONE_SHOT)

		get_tree().reload_current_scene()
		
func _on_player_death_finished():
	print("Reloading scene...")
	get_tree().reload_current_scene()
