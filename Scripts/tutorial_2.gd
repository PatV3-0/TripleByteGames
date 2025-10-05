extends Area2D

@export var bod: CharacterBody2D
@export var tutorial_canvas: Node 
var triggered := false

var tutorial_lines = [
	["Oh great! I spilled the tea!", 5.0],
	["Is the shrinking magic causing these fumes?", 5.0],
	["Mmmm... I wonder if I enter them...", 5.0]
]

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func _on_body_entered(body):
	if body == bod and not triggered:  # Adjust check for your player
		triggered = true
		tutorial_canvas.start_lines(tutorial_lines,self)
