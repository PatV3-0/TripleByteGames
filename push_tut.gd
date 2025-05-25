extends Area2D

@onready var p_sprite = get_node("../../PKey")  # one level up then child

func _ready() -> void:
	#print(p_sprite)
	#print(monitoring)
	p_sprite.visible = false  # hide it initially
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	#print("Entered:", body.name)
	if body.is_in_group("Player"):
		p_sprite.visible = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		p_sprite.visible = false
