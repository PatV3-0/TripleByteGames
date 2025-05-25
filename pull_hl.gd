extends Area2D

@onready var hl_sprite = $"../PullBox/HL"
@onready var okey = $"../../OKey"
var o_pressed = false

func _ready() -> void:
	# Ensure HL is hidden initially
	if hl_sprite:
		hl_sprite.visible = false
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if o_pressed == false:
			okey.visible = true
		#print("Player entered, showing HL")
		if hl_sprite:
			hl_sprite.visible = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		#print("Player exited, hiding HL")
		if hl_sprite:
			hl_sprite.visible = false
			
func _physics_process(_delta: float) -> void:
	if not o_pressed and Input.is_action_just_pressed("toggle_pull"):
		o_pressed = true
