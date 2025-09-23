extends Area2D

@export var bod: CharacterBody2D
@export var tutorial_canvas: Node 
@export var stand_time: float = 1.0
var triggered := false

var tutorial_lines = [
	["Use ‘w’ to crawl through a hole.", 1.0]
]

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
		#print("Inside!!!")
		player_inside = true
		timer = 0.0
		last_pos = bod.global_position  # initialize

func _on_body_exited(body):
	if tutorial_done:
		return
	if body is CharacterBody2D:
		#print("Left")
		player_inside = false
		timer = 0.0

func _physics_process(delta):
	if tutorial_done:
		return
	if Input.is_action_just_pressed("enter_door"):
		print("Tutorial cancelled by W press")
		var tutorial = get_tree().current_scene.get_node("TutorialCanvas")
		if is_instance_valid(tutorial):
			tutorial.cancel_tutorial()
		tutorial_done = true
		return
	if player_inside and bod:
		var moved = bod.global_position.distance_to(last_pos)
		if moved < 1.0:  # essentially stationary
			timer += delta
			if timer >= stand_time:
				#print("Playing")
				player_inside = false
				tutorial_done = true
				emit_signal("show_w_key")  # emit signal to main scene
				if not triggered:  # Adjust check for your player
					triggered = true
					tutorial_canvas.start_lines(tutorial_lines,self)
					

		else:
			timer = 0.0
		last_pos = bod.global_position

	
