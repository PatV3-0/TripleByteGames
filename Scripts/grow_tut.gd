extends Area2D

@export var tutorial_element: Node

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is CharacterBody2D:
		# Check if the player has a 'grow_count' variable or 'grow' method
		if "grow_count" in body:
			# Only trigger tutorial if player has grown at least once
			if body.grow_count > 0:
				_show_tutorial()
		else:
			# Fallback: only trigger if tutorial_element exists (optional)
			_show_tutorial()

func _show_tutorial():
	if tutorial_element:
		tutorial_element.visible = true
		if tutorial_element.has_method("play"):
			tutorial_element.play()

		if tutorial_element is AnimatedSprite2D:
			if not tutorial_element.is_connected("animation_finished", Callable(self, "_on_tutorial_finished")):
				tutorial_element.animation_finished.connect(_on_tutorial_finished)

func _on_tutorial_finished():
	if tutorial_element:
		tutorial_element.visible = false
