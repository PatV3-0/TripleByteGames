extends RigidBody2D

@export var lifetime: float = 10.0

func _ready():
	apply_impulse(Vector2.ZERO, Vector2(300, 0))
	apply_torque_impulse(200)

func _start_rolling():
	print("Rolling")
	apply_impulse(Vector2.ZERO, Vector2(300, 50))
	apply_torque_impulse(200)

func _process(delta):
	#Sprint(global_position.x)
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
