extends Area2D

@onready var label = $Label  # AnimatedSprite2D
@onready var hl = $"../Highlight"

var has_triggered := false

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	label.connect("animation_finished", Callable(self, "_on_label_animation_finished"))
	label.visible = false  # Hide label initially

func _on_body_entered(body):
	if has_triggered:
		return

	if body.is_in_group("Player"):
		has_triggered = true
		label.visible = true
		label.play("default")
		hl.set_deferred("monitoring", true)
		#monitoring = false  # Optional: disables physics processing for this area

func _on_label_animation_finished() -> void:
	label.visible = false
