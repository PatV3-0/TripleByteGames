extends Area2D

@export var bod: CharacterBody2D

var tutorial_done: bool = false  # Tracks whether tutorial has already played

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if tutorial_done:
		return  # Don't trigger again

	if body is CharacterBody2D:
		if bod:
			tutorial_done = true  # Mark tutorial as done
			bod.show_tutorial()
			await get_tree().create_timer(1.0).timeout
			bod.show_tutorial_text("Objects may highlight as you approach.")
			await get_tree().create_timer(5.0).timeout
			bod.show_tutorial_text("You can push or pull these objects.")
			await get_tree().create_timer(5.0).timeout
			bod.show_tutorial_text("")
			await get_tree().create_timer(0.5).timeout
			bod.hide_tutorial_text()
			await get_tree().create_timer(0.5).timeout
			bod.hide_tutorial()
