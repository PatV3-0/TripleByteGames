extends Area2D

@export var bod: CharacterBody2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is CharacterBody2D:
		if bod:
			bod.show_tutorial()
			await get_tree().create_timer(1.0).timeout
			bod.show_tutorial_text("Would you look at that! I'm bigger!")
			await get_tree().create_timer(5.0).timeout
			bod.show_tutorial_text("I'd better keep an eye out for more of these spills...")
			await get_tree().create_timer(5.0).timeout
			bod.show_tutorial_text("")
			await get_tree().create_timer(0.5).timeout
			bod.hide_tutorial_text()
			await get_tree().create_timer(0.5).timeout
			bod.hide_tutorial()
