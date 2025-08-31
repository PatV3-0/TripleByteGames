extends Area2D

@export var bod: CharacterBody2D
@export var stand_time: float = 1.0

signal show_w_key

var timer := 0.0
var player_inside := false
var last_pos: Vector2
var tutorial_done = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body is CharacterBody2D:
		print("Inside!!!")
		player_inside = true
		timer = 0.0
		last_pos = bod.global_position  # initialize

func _on_body_exited(body):
	if tutorial_done:
		return
	if body is CharacterBody2D:
		print("Left")
		player_inside = false
		timer = 0.0

func _physics_process(delta):
	if tutorial_done:
		return
	if player_inside and bod:
		var moved = bod.global_position.distance_to(last_pos)
		if moved < 1.0:  # essentially stationary
			timer += delta
			if timer >= stand_time:
				print("Playing")
				player_inside = false
				tutorial_done = true
				emit_signal("show_w_key")  # emit signal to main scene
				await _play_tutorial()
		else:
			timer = 0.0
		last_pos = bod.global_position

func _play_tutorial() -> void:
	print("tut")
	bod.show_tutorial()
	await get_tree().create_timer(1.0).timeout
	bod.show_tutorial_text("Sometimes there’s a small gap to squeeze through...")
	await get_tree().create_timer(5.0).timeout
	bod.show_tutorial_text("Use ‘w’ to crawl through a hole.")
	await get_tree().create_timer(5.0).timeout
	bod.show_tutorial_text("")
	await get_tree().create_timer(0.5).timeout
	bod.hide_tutorial_text()
	await get_tree().create_timer(0.5).timeout
	bod.hide_tutorial()
