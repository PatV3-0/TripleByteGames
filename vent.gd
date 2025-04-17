extends RigidBody2D

@export var attached_object: RigidBody2D
@onready var area: Area2D = $Area2D 

var shaking = false
var shake_duration = 0.7
var shake_magnitude = 1.0
var shake_timer = 0.0

func _ready():
	freeze_mode()
	attached_object = get_parent().get_node("Plug")
	area.body_entered.connect(self._on_body_entered)

func freeze_mode():
	freeze = true
	sleeping = true
	gravity_scale = 0

func shake():
	shaking = true
	shake_timer = shake_duration
	attached_object.changeState()

func release():
	freeze = false
	sleeping = false
	gravity_scale = 1

func _on_body_entered(body):
	if body == attached_object:
		if attached_object.has_method("activate"):
			attached_object.activate()  # Activate the plug to fall

func _process(delta):
	if shaking:
		var shake_offset = Vector2(randf_range(-shake_magnitude, shake_magnitude), randf_range(-shake_magnitude, shake_magnitude))
		position += shake_offset
		shake_timer -= delta
		
		if shake_timer <= 0:
			shaking = false
			release()  # Release the block after shaking
