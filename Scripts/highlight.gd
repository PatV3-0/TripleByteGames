extends Area2D

@onready var tutorial_area = $"../CollisionShape2D/Sprite2D"
@onready var p_sprite = get_node("../../PKey")
@onready var o_sprite = get_node("../../OKey")

var has_shown_keys := false

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if tutorial_area:
			tutorial_area.visible = true
			tutorial_area.set_deferred("monitoring", true)

		if not has_shown_keys:
			p_sprite.visible = true
			o_sprite.visible = true
			has_shown_keys = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		if tutorial_area:
			tutorial_area.visible = false
			tutorial_area.set_deferred("monitoring", false)
