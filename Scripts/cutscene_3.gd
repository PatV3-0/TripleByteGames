extends Node2D

@export var next_scene_path: String = "res://Scenes/Kitchen3.tscn"

func _ready() -> void:
	# Play the animation
	$Sprite2D.play("default")
	# Connect the signal for when the animation ends
	$Sprite2D.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	# Start the fade when animation is done
	var fade_rect = $FadeLayer/FadeRect
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Wait for the fade to finish before changing scene
	tween.finished.connect(_on_fade_done)

func _on_fade_done() -> void:
	get_tree().change_scene_to_file(next_scene_path)
