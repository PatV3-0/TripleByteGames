extends Area2D

@onready var canvas = $"../CanvasLayer"
@onready var col = $"../CanvasLayer/ColorRect"
@onready var sprite = $"../CanvasLayer/Sprite2D"

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	col.visible = false
	sprite.visible = false
	_center_elements()

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:  # only trigger for player
		print("Ingredient found")
		#col.visible = true
		sprite.visible = true
		_center_elements()  # recenter
		await get_tree().create_timer(4.0).timeout
		col.visible = false
		sprite.visible = false

func _center_elements():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Center the ColorRect
	col.position = (viewport_size - col.size) / 2
	
	# Center the Sprite if it has a texture
	if sprite.texture:
		var val = sprite.texture.get_size() - Vector2(900,650)
		sprite.position = (viewport_size - val) / 2
