extends Area2D

@onready var collision_shape = $CollisionShape2D

@export var trigger_tutorial_on_growth: bool = false
@export var tutorial_area: Area2D  # Drag your tutorial Area2D here if needed

func _ready():
	$Sprite2D.play("default")
	connect("body_entered", Callable(self, "_on_body_entered"))

var pending_hide := false

func _on_body_entered(body):
	if body.is_in_group("Player"):
		
		var grew = false
		if body.has_method("shrink"):
			grew = await body.shrink(-105)
			if grew:
				$Sprite2D.visible = false

		if trigger_tutorial_on_growth and grew and tutorial_area:
			if tutorial_area.has_method("_on_body_entered"):
				tutorial_area._on_body_entered(body)

		collision_shape.set_deferred("disabled", true)
		pending_hide = true
		
func _on_animation_finished():
	if pending_hide:
		hide()
