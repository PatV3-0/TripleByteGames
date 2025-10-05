extends Area2D

@export var next_scene_path: String = "res://Scenes/KitchenCut.tscn"
@onready var fade_rect = $"../FadeLayer/FadeRect"

var player_inside: Node = null
var transitioning := false

func _physics_process(_delta: float) -> void:
	if player_inside and not transitioning:
		# Wait for player to press W (or your "enter_door" action)
		if Input.is_action_just_pressed("enter_door"):
			transitioning = true
			transition_to_next_scene()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player_inside = body
		transitioning = false

func _on_body_exited(body: Node) -> void:
	if body == player_inside:
		player_inside = null
		transitioning = false

func transition_to_next_scene():
	var tutorial = get_tree().current_scene.get_node("TutorialCanvas")
	if is_instance_valid(tutorial):
		tutorial.cancel_tutorial()
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	get_tree().change_scene_to_file(next_scene_path)
