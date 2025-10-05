extends Area2D

@export var bod: CharacterBody2D
@export var tutorial_canvas: Node 
var triggered := false

var tutorial_lines = [
	["I'm sure I'll be able to fit through the cat flap...", 5.0]
]

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func _on_body_entered(body):
	if body == bod and not triggered:  # Adjust check for your player
		triggered = true
		tutorial_canvas.start_lines(tutorial_lines,self)
