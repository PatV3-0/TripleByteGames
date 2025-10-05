extends Node

signal checklist_updated(key)
var prev_list: Dictionary = {}

var checklist_values = {
	"mushroom": false,
	"flower": false,
	"beetle": false,
	"salt": false,
	"garlic": false
}


func set_checklist_value(key: String, value: bool) -> void:
	checklist_values[key] = value
	emit_signal("checklist_updated", key)

func collect_all_ingredients():
	prev_list = checklist_values.duplicate(true)
	for key in checklist_values.keys():
		checklist_values[key] = true
		emit_signal("checklist_updated", key)

func reset_ingredients():
	if prev_list != null:
		for key in prev_list.keys():
			checklist_values[key] = prev_list[key]
			emit_signal("checklist_updated", key)
