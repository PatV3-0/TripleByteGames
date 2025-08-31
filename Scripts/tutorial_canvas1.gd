extends CanvasLayer

@onready var background: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $TutLabel

func _ready():
	print("Label resolved in _ready():", label)
	background.visible = true
	
func follow_player(player_pos: Vector2):
	var cam = get_viewport().get_camera_2d()
	if cam:
		# In Godot 4.3, world-to-screen is simply player_pos minus camera position + viewport center
		var screen_center = get_viewport().get_visible_rect().size / 2
		var screen_pos = screen_center + (player_pos - cam.global_position)
		background.position = screen_pos + Vector2(5, 260)
		label.position = screen_pos + Vector2(-385, 225)

func show_tutorial():
	background.play("expand")
	label.visible = true

func hide_tutorial():
	background.play("retract")
	await background.animation_finished
	label.visible = false

func show_tutorial_text(text: String):
	label.text = text
	label.visible = true

func hide_tutorial_text():
	label.visible = false
