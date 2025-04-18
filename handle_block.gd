extends Node2D

@onready var area = $Handle
@onready var collider = $StaticBody2D/CollisionShape2D

var is_triggered = false
var target_y = 0.0
var pull_speed = 80.0
var player_ref: CharacterBody2D = null  # Reference to the player

func _ready():
	collider.disabled = true
	area.connect("body_entered", _on_handle_hit)

func _on_handle_hit(body):
	if is_triggered:
		return
	
	if body.name == "Player" and body.velocity.y < 0:
		is_triggered = true
		target_y = position.y + 30  # The distance to pull the handle
		player_ref = body
		# Optional: disable player's movement if needed
		player_ref.set_physics_process(false)

func _process(delta):
	if is_triggered and position.y < target_y:
		position.y = move_toward(position.y, target_y, pull_speed * delta)
		
		if player_ref:
			# Make the player "hang" onto the bottom of the handle
			player_ref.global_position.x = global_position.x  # Keep the player aligned horizontally
			player_ref.global_position.y = global_position.y + 10  # Align player under the handle

		if position.y >= target_y:
			_finalize_block()

func _finalize_block():
	collider.disabled = false
	area.queue_free()

	if player_ref:
		# Slightly offset down so they're no longer inside the collider
		player_ref.global_position.y += 10
		player_ref.release_from_handle()
		player_ref = null
