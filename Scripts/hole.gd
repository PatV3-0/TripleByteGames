extends Area2D

@export var next_scene_path: String = "res://Scenes/main_menu.tscn"
@onready var fade_rect = $"../FadeLayer/FadeRect"

var player_inside: Node = null
var still_time := 0.0
const STILL_THRESHOLD := 1.0
const STAND_STILL_EPSILON := 1.0  # how much movement counts as "still"

var last_player_pos := Vector2.ZERO
var transitioning := false

func _physics_process(delta: float) -> void:
	if player_inside and not transitioning:
		var current_pos = player_inside.global_position
		if current_pos.distance_to(last_player_pos) <= STAND_STILL_EPSILON:
			still_time += delta
			if still_time >= STILL_THRESHOLD:
				transitioning = true
				transition_to_next_scene()
		else:
			still_time = 0.0
		last_player_pos = current_pos

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player_inside = body
		last_player_pos = body.global_position
		still_time = 0.0
		transitioning = false

func _on_body_exited(body: Node) -> void:
	if body == player_inside:
		player_inside = null
		still_time = 0.0
		transitioning = false

func transition_to_next_scene():
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	get_tree().change_scene_to_file(next_scene_path)
