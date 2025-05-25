extends Area2D

@onready var pull_tut = $"../../PullTut1"
@onready var pull_hl = $"../PullHL"


func _ready() -> void:
	monitoring = false
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("Player"): 
		#print("active")
		pull_tut.visible = true
		pull_tut.play()
		monitoring = false
		pull_hl.monitoring = true
