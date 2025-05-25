extends Area2D

@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Sprite2D

func _ready():
	sprite.play("default")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("grow"):
			body.grow(-110)
		collision_shape.set_deferred("disabled", true)

		sprite.play("poof")
		$"../PortalPoof".play()
		await sprite.animation_finished
		hide()
