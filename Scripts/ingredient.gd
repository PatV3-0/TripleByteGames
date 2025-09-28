extends Area2D

@export var i_name: String
@onready var canvas = $"../CanvasLayer"
@onready var col = $"../CanvasLayer/ColorRect"
@onready var sprite = $"../CanvasLayer/Sprite2D"
@onready var in_game_sprite = $Sprite2D

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
		await get_tree().create_timer(3.0).timeout
		col.visible = false
		sprite.visible = false
		canvas.visible = false
		in_game_sprite.visible = false
		if i_name in Ingredients.checklist_values:
			Ingredients.set_checklist_value(i_name, true)
			print("Checklist updated:", i_name, Ingredients.checklist_values[i_name])
			get_tree().call_group("checklist", "update_texture")
		else:
			print("Checklist key not found:", i_name)

func _center_elements():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Center the ColorRect
	col.position = (viewport_size - col.size) / 2
	
	# Center the Sprite if it has a texture
	if sprite.texture:
		var val = sprite.texture.get_size() - Vector2(900,650)
		sprite.position = (viewport_size - val) / 2
