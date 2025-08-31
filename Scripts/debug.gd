extends Node2D

@export var show_collisions: bool = true
@export var collision_color: Color = Color.RED  # change if you want a different color

func _ready():
	# Optional: move this node under a CanvasLayer so it always appears on top
	var canvas = get_tree().current_scene.get_node_or_null("DebugCanvasLayer")
	if not canvas:
		canvas = CanvasLayer.new()
		canvas.name = "DebugCanvasLayer"
		canvas.layer = 1000
		get_tree().current_scene.add_child(canvas)
	canvas.add_child(self)

func _draw():
	if not show_collisions:
		return

	# Iterate through all CollisionShape2D nodes in the scene
	for shape in get_tree().get_nodes_in_group("CollisionShape2D"):
		if not shape.shape:
			continue

		var t = shape.get_global_transform()
		match shape.shape:
			CircleShape2D:
				draw_circle(t.origin, shape.shape.radius, collision_color)
			RectangleShape2D:
				draw_rect(Rect2(t.origin - shape.shape.extents, shape.shape.extents * 2), collision_color, false)
			CapsuleShape2D:
				# Approximate capsule with circle + rect
				var r = shape.shape.radius
				var h = shape.shape.height
				draw_rect(Rect2(t.origin.x - r, t.origin.y - h/2, r*2, h), collision_color, false)
				draw_circle(t.origin + Vector2(0, -h/2), r, collision_color)
				draw_circle(t.origin + Vector2(0, h/2), r, collision_color)

func _process(_delta):
	if show_collisions:
		update()  # triggers _draw()
