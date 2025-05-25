extends Area2D

@onready var pull_tut = $"../PullTut"  # Adjust this path to your scene structure

func _ready() -> void:
	#print(pull_tut)
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	#print(body)
	if body is CharacterBody2D:  # Or use `body.is_in_group("Player")` 
		if pull_tut:
			pull_tut.monitoring = true
			#print("PullTut activated!")
