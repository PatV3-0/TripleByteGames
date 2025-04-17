extends RigidBody2D

func _ready():
	freeze = true
	sleeping = true
	gravity_scale = 0
	set_collision_layer_value(1, false)  # Layer 1 = Interactable OFF
	set_collision_layer_value(2, true)   # Layer 2 = Non-interactable ON
	
func changeState():
	set_collision_layer_value(1, true)  # Layer 1 = Interactable OFF
	set_collision_layer_value(2, false)   # Layer 2 = Non-interactable ON

func make_pushable():
	freeze = false
	sleeping = false
	gravity_scale = 1
	set_sleeping(false)

func activate():
	await get_tree().create_timer(0.01).timeout
	freeze = false
	sleeping = false
	gravity_scale = 1
	make_pushable()


	
