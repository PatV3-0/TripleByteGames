extends Area2D

@onready var p_sprite = get_node("../../PKey")  # one level up then child
@onready var highlight_sprite = get_parent().get_node("CollisionShape2D9/HighlightSprite")

var player_in_area = false
var deactivated = false

func _ready() -> void:
	#print("HL Node:", hl)
	p_sprite.visible = false  # hide it initially
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	highlight_sprite.visible = false  # Hide highlight by default

func _on_body_entered(body):
	#print("Highligthing")
	if body.is_in_group("Player"):
		player_in_area = true
		highlight_sprite.visible = true
		p_sprite.visible = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_area = false
		highlight_sprite.visible = false
		p_sprite.visible = false

func _process(_delta: float) -> void:
	if not deactivated and player_in_area and Input.is_action_just_pressed("toggle_push"):
		# Hide and deactivate after pressing P
		highlight_sprite.visible = false
		#print("Activate next area")
		monitoring = false
		deactivated = true
		
	if deactivated:
		highlight_sprite.visible = false
