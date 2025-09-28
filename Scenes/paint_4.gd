extends Area2D

@export var target_character: CharacterBody2D   # The player node
@export var fall_speed: float = 500.0

var should_fall: bool = false
var painting_body: StaticBody2D = null

func _ready() -> void:
	self.body_exited.connect(_on_body_exited)
	painting_body = get_parent() as StaticBody2D

func _physics_process(delta: float) -> void:
	if should_fall and painting_body:
		painting_body.position.y += fall_speed * delta

func _on_body_exited(body: Node) -> void:
	if body == target_character:
		should_fall = true
