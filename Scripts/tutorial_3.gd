extends Area2D

@export var bod: CharacterBody2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is CharacterBody2D:
		if bod:
			bod.show_tutorial()
			await get_tree().create_timer(1.0).timeout
			bod.show_tutorial_text("Oh! Jameson's bed!")
			await get_tree().create_timer(6.0).timeout
			bod.show_tutorial_text("That'll soften the fall quite nicely.")
			await get_tree().create_timer(6.0).timeout
			bod.show_tutorial_text("Once I'm big, I ought to reward him with some tuna.")
			await get_tree().create_timer(6.0).timeout
			bod.hide_tutorial_text()
			await get_tree().create_timer(1.0).timeout
			bod.hide_tutorial()
