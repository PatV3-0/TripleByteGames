extends Area2D

@onready var tutorial_element = get_node("../Tut1")

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is CharacterBody2D and tutorial_element:
		if tutorial_element is AnimatedSprite2D:
			if not tutorial_element.is_playing():
				tutorial_element.visible = true
				tutorial_element.frame = 0  # Reset to first frame
				await get_tree().process_frame  # Wait to ensure visibility is updated
				tutorial_element.play()
				if not tutorial_element.is_connected("animation_finished", Callable(self, "_on_tutorial_finished")):
					tutorial_element.animation_finished.connect(_on_tutorial_finished)
		else:
			tutorial_element.visible = true
			if tutorial_element.has_method("play"):
				tutorial_element.play()

func _on_tutorial_finished():
	if tutorial_element:
		tutorial_element.visible = false
