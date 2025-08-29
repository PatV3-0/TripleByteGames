extends Area2D

@onready var tutorial_area = $"../CollisionShape2D/Sprite2D"

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if tutorial_area:
			tutorial_area.visible = true
			tutorial_area.set_deferred("monitoring", true)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		if tutorial_area:
			tutorial_area.visible = false
			tutorial_area.set_deferred("monitoring", false)
