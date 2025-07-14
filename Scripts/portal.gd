extends Area2D

@onready var collision_shape = $CollisionShape2D
@onready var sprite = $CollisionShape2D/Sprite2D

@export var trigger_tutorial_on_growth: bool = false
@export var tutorial_area: Area2D  # Drag your tutorial Area2D here if needed

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var grew = false
		if body.has_method("grow"):
			grew = body.grow(105)

		# Trigger tutorial only if player actually grew
		if trigger_tutorial_on_growth and grew and tutorial_area:
			if tutorial_area.has_method("_on_body_entered"):
				tutorial_area._on_body_entered(body)

		collision_shape.set_deferred("disabled", true)
		hide()
