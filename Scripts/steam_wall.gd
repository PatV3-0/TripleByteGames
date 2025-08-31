extends Node2D

@export var rise_speed: float = 60.0
@export var lifetime: float = 6.0

func _process(delta: float) -> void:
	# move upwards
	#print("Steam Y:", position.y)
	position.y -= rise_speed * delta

	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.queue_free() # or call your player's death function
