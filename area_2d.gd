# Script on Area2D child node
extends Area2D

signal player_in_range_changed(in_range: bool, player: Node)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "CharacterBody2D":
		#print("Can pull")
		emit_signal("player_in_range_changed", true, body)

func _on_body_exited(body):
	if body.name == "CharacterBody2D":
		emit_signal("player_in_range_changed", false, null)
