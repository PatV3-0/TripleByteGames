extends Area2D

@export var launch_strength: Vector2 = Vector2(0, -1000)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("launch"):
		# only launch if player is falling downwards
		if body.velocity.y > 0:
			body.launch(launch_strength)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
