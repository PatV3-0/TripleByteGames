extends Area2D

@onready var collision_shape = $CollisionShape2D
#@onready var sprite = $Green
#@onready var sprite2 = $Yellow

@export var trigger_tutorial_on_growth: bool = false
@export var tutorial_area: Area2D  # Drag your tutorial Area2D here if needed

func _ready():
	#print(sprite)
	connect("body_entered", Callable(self, "_on_body_entered"))
	#if sprite and sprite.has_signal("animation_finished"):
		#sprite.animation_finished.connect(_on_animation_finished)

var pending_hide := false

func _on_body_entered(body):
	if body.is_in_group("Player"):
		#sprite.play("Pop")
		#sprite2.play("Pop")

		var grew = false
		if body.has_method("shrink"):
			grew = body.shrink(-105)
			if grew:
				$Sprite2D.visible = false

		# Trigger tutorial only if player actually grew
		if trigger_tutorial_on_growth and grew and tutorial_area:
			if tutorial_area.has_method("_on_body_entered"):
				tutorial_area._on_body_entered(body)

		collision_shape.set_deferred("disabled", true)
		pending_hide = true
		
func _on_animation_finished():
	if pending_hide:
		hide()
