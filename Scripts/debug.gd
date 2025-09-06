# DebugCollisions.gd
extends Node

@export var show_collisions: bool = true
@export var collision_color: Color = Color.RED

var drawer: CollisionDrawer

func _ready():
	# CanvasLayer to draw on top of everything
	var canvas = CanvasLayer.new()
	canvas.layer = 1000
	get_tree().current_scene.add_child(canvas)

	# Subclass Node2D that handles drawing
	drawer = CollisionDrawer.new()
	drawer.show_collisions = show_collisions
	drawer.collision_color = collision_color
	canvas.add_child(drawer)

	func _process(_delta):
		if show_collisions:
			drawer.update()  # now valid in a proper Node2D subclass


# Subclass Node2D for drawing
class CollisionDrawer:
	extends Node2D

	var show_collisions: bool = true
	var collision_color: Color = Color.RED

	func _draw():
		if not show_collisions:
			return

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
					var r = shape.shape.radius
					var h = shape.shape.height
					draw_rect(Rect2(t.origin.x - r, t.origin.y - h/2, r*2, h), collision_color, false)
					draw_circle(t.origin + Vector2(0, -h/2), r, collision_color)
					draw_circle(t.origin + Vector2(0, h/2), r, collision_color)

	func _process(_delta):
		if show_collisions:
			update()  # Node2D's update() is now valid
