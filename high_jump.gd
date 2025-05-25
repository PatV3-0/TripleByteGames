extends Area2D

@onready var tutorial_area = $"../TutArea"

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		#print("Triggered")
		if tutorial_area:
			tutorial_area.visible = true
			tutorial_area.set_deferred("monitoring", true)
