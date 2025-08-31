extends CanvasLayer

@onready var background = $AnimatedSprite2D
@onready var label = $TutLabel

func _ready():
	print(label)  # should not be null
	for child in get_children():
		print(child.name)

func show_tutorial():
	#background.play("expand")
	#label.visible = true
	pass

func hide_tutorial():
	#background.play("retract")
	#await background.animation_finished
	#label.visible = false
	pass

func show_tutorial_text(text: String):
	#label.text = text
	#label.visible = true
	pass

func hide_tutorial_text():
	#label.visible = false
	pass
