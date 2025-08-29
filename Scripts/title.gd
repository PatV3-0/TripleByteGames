extends Node2D

@onready var sprite1: AnimatedSprite2D = $Sprite2D
@onready var sprite2: Sprite2D = $Sprite2D2
@onready var bg_color: ColorRect = $ColorRect
@onready var fade_rect: ColorRect = $FadeRect

func _ready():
	sprite1.visible = false
	sprite2.visible = false
	bg_color.color = Color("#ffa555")       # Starting background color
	fade_rect.color = Color.BLACK
	fade_rect.modulate.a = 0           # Fully transparent

	# Start the animation sequence
	start_sequence()

func start_sequence() -> void:
	await get_tree().create_timer(1.0).timeout      # Wait 1 second

	sprite1.visible = true
	sprite1.play("default")                         # Make sure your animation is named "default"

	# Wait for the animation to finish
	await sprite1.animation_finished

	await get_tree().create_timer(1.0).timeout      # Wait 1 second

	# Change background to dark grey
	bg_color.color = Color(0.2, 0.2, 0.2)          # RGB values between 0 and 1

	# Show second sprite
	sprite2.visible = true

	await get_tree().create_timer(3.0).timeout      # Wait 3 seconds

	# Fade to black
	var tween = get_tree().create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

	# Change scene to main menu
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
