extends Area2D

@export var tilt_amount: float = 10.0 # amount to lean (scale difference)
@export var tilt_speed: float = 5.0
@export var painting_width: float 
@export var target_character: CharacterBody2D
@export var detection_shape: CollisionShape2D
@export var physics_shape: CollisionShape2D
@onready var visual: Node2D = get_parent().get_node("Sprite2D")
var player_inside: bool = false

func _ready():
	painting_width = detection_shape.shape.extents.x * 2
	self.body_entered.connect(Callable(self, "_on_body_entered"))
	self.body_exited.connect(Callable(self, "_on_body_exited"))

func _physics_process(delta):
	if player_inside and target_character:
		var local_pos: Vector2 = target_character.global_position - visual.global_position
		var offset: float = clamp(local_pos.x / (painting_width/2.0), -1.0, 1.0)

		var target_tilt: float = offset * tilt_amount
		print("Rotating:", target_tilt)

		visual.rotation = lerp(visual.rotation, deg2rad(target_tilt), delta * tilt_speed)
		detection_shape.rotation = lerp(detection_shape.rotation, deg2rad(target_tilt), delta * tilt_speed)
		physics_shape.rotation = lerp(physics_shape.rotation, deg2rad(target_tilt), delta * tilt_speed)
	else:
		visual.rotation = lerp(visual.rotation, 0.0, delta * tilt_speed)
		detection_shape.rotation = lerp(detection_shape.rotation, 0.0, delta * tilt_speed)
		physics_shape.rotation = lerp(physics_shape.rotation, 0.0, delta * tilt_speed)

func _on_body_entered(body):
	print("Player entered painting area")
	if body == target_character:
		player_inside = true
		print("Player inside painting area")

func _on_body_exited(body):
	print("Player left painting area")
	if body == target_character:
		player_inside = false
		print("Player out painting area")
		
func deg2rad(deg: float) -> float:
	return deg * PI / 180.0
