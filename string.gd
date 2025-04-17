extends Node2D

@onready var area = $String
@onready var collider = $StaticBody2D/CollisionShape2D

var is_triggered = false
var target_y = 0.0
var pull_speed = 80.0
var player_ref: CharacterBody2D = null
var falling_block: RigidBody2D = null

func _ready():
	collider.disabled = true
	area.connect("body_entered", _on_string_hit)
	
	falling_block = get_parent().get_node("Vent")

func _on_string_hit(body):
	if is_triggered:
		return

	if body.name == "Player" and body.velocity.y < 0:
		is_triggered = true
		target_y = position.y + 30
		player_ref = body
		player_ref.set("can_move", false)  # Freeze player input

func _process(delta):
	if is_triggered and position.y < target_y:
		position.y = move_toward(position.y, target_y, pull_speed * delta)

		if position.y >= target_y:
			_finalize_pull()

func _finalize_pull():
	collider.disabled = true
	await get_tree().create_timer(0.2).timeout  # Pause briefly after string finishes pulling

	if player_ref:
		player_ref.set("can_move", true)  # Re-enable control
		player_ref = null

	_trigger_event()

func _trigger_event():
	if falling_block:
		falling_block.shake()
