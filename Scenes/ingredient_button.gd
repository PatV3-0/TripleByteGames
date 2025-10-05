extends TextureButton

@export var option_name : String # matches checklist_values key
@export var texture_unselected : Texture2D
@export var texture_selected : Texture2D

func _ready():
	update_texture()
	Ingredients.connect("checklist_updated", Callable(self, "update_texture"))

	
func update_texture(changed_key: String = ""):
	if changed_key == "" or changed_key == option_name:
		if Ingredients.checklist_values[option_name]:
			texture_normal =   texture_selected 
		else:
			texture_normal =  texture_unselected
		
