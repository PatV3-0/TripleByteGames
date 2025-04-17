extends Area2D

var player_inside := false
var player : CharacterBody2D = null
var still_time := 0.0
const STAND_STILL_THRESHOLD := 1.0  # seconds of stillness required

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "Player":
		player_inside = true
		player = body
		still_time = 0.0

func _on_body_exited(body):
	if body.name == "Player":
		player_inside = false
		player = null
		still_time = 0.0

func _process(delta):
	if player_inside and player:
		if player.velocity.length() < 1:  # Basically not moving
			still_time += delta
			if still_time > STAND_STILL_THRESHOLD:
				trigger_level_end()
		else:
			still_time = 0.0
			
func trigger_level_end():
	if get_tree().paused:
		return  # avoid triggering during pause
	#get_tree().paused = true  # Optional: Freeze input during fade
	var parent = get_tree().current_scene
	parent.call_deferred("start_fade_to_black")
