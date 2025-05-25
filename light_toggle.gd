extends Area2D

@export var drop_distance: float = 3.0
@export var drop_duration: float = 0.5

var player: Node2D = null
var activated = false

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D" and not activated:
		activated = true
		player = body
		player.call_deferred("freeze")

		call_deferred("_reparent_player")
		await get_tree().create_timer(0.2).timeout
		_start_descent()

func _reparent_player():
	if player:
		var sprite = player.get_node("Sprite2D")
		sprite.stop()
		var global_pos = player.global_position
		# Remove from current parent first
		var original_parent = player.get_parent()
		if original_parent:
			original_parent.remove_child(player)
		# Create a neutral wrapper
		var wrapper = Node2D.new()
		wrapper.scale = Vector2(1.0 / scale.x, 1.0 / scale.y)  # counteract parent's scale
		add_child(wrapper)
		wrapper.add_child(player)
		# Restore player's global position
		player.global_position = global_pos
		#print("Completed")

func _start_descent():
	#print("Before tween - pos:", $Sprite2D2.position)
	var tween = create_tween()
	tween.tween_property(self, "position:y", -2104.5, drop_duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property($Sprite2D, "position:y", 98.3311, drop_duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property($Sprite2D2, "position:y", -826.97, drop_duration).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(Callable(self, "_fade_to_black"))
	await tween.finished
	#print("After tween - pos:", $Sprite2D2.position)

func _fade_to_black():
	var fade_rect = $"../CanvasLayer/ColorRect"
	fade_rect.visible = true
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)

#func _process(delta):
	#print("Sprite2D global position:", $Sprite2D.global_position)
