extends Area2D

@export var bod: CharacterBody2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is CharacterBody2D:
		if bod:
			bod.show_tutorial()
			await get_tree().create_timer(1.0).timeout
			bod.show_tutorial_text("Oh great! Of course I spilled the tea!")
			await get_tree().create_timer(6.0).timeout
			bod.show_tutorial_text("The same shrinking magic may be causing this...")
			await get_tree().create_timer(6.0).timeout
			bod.show_tutorial_text("I wonder what it does.")
			await get_tree().create_timer(6.0).timeout
			bod.hide_tutorial_text()
			await get_tree().create_timer(1.0).timeout
			bod.hide_tutorial()
