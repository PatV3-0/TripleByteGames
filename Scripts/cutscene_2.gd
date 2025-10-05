extends Node2D

@export var next_scene_path: String = "res://Scenes/Kitchen1.tscn"

func _ready() -> void:
	$Background.play()
	await get_tree().create_timer(5.0).timeout  
	
	var fade_rect = $FadeLayer/FadeRect
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	get_tree().change_scene_to_file(next_scene_path)

func _process(delta: float) -> void:
	pass
