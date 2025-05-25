extends Area2D

@onready var pull_tut = $"../../PullTut1"
@onready var pull_hl = $"../PullHL"

func _ready() -> void:
	monitoring = false
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Connect animation_finished signal from AnimatedSprite2D
	pull_tut.connect("animation_finished", Callable(self, "_on_pull_tut_animation_finished"))

func _on_body_entered(body):
	if body.is_in_group("Player"): 
		pull_tut.visible = true
		pull_tut.play()
		monitoring = false
		pull_hl.monitoring = true

func _on_pull_tut_animation_finished():
	# Hide the animated sprite when its animation finishes
	pull_tut.visible = false
