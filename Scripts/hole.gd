extends Area2D

@export var next_scene_path: String = "res://Scenes/Level2.tscn"
@onready var fade_rect = get_tree().get_root().get_node("TutorialScene/FadeLayer/FadeRect")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		print("Player entered the hole, transitioning...")
		transition_to_next_scene()

func transition_to_next_scene():
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	get_tree().change_scene_to_file(next_scene_path)
