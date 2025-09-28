extends Area2D

@export var target_character: CharacterBody2D   # The player node
@export var player_size_required: int = 1      # The size that triggers the fall
@export var fall_speed: float = 500.0

var should_fall: bool = false
var painting_body: StaticBody2D = null

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	painting_body = get_parent() as StaticBody2D  # Painting root node

func _physics_process(delta: float) -> void:
	if should_fall and painting_body:
		painting_body.position.y += fall_speed * delta

func _on_body_entered(body: Node) -> void:
	if body == target_character:
		if target_character.size == player_size_required:
			should_fall = true
