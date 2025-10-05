extends Node

const savePath = "user://"
const saveSlotCount = 3

#example save struct:
#{
#	"playerName": "Player1",
#	"lastUnlockedLevel": 3,
#	"timeStamp": "2025-04-07 12:45"
#}

func saveGame(slot: int, data: Dictionary) -> void:
	if slot < 1 or slot > saveSlotCount:
		print("Invalid save slot:", slot)
		return
		
	var filePath = savePath + "saveSlot" + str(slot) + ".json"
	var file = FileAccess.open(filePath, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("Game saved to slot", slot)
#func saveGame(data: Dictionary) -> void:
	#var filePath = savePath + "save.json"
	#var file = FileAccess.open(filePath, FileAccess.WRITE)
	#if file:
		#file.store_string(JSON.stringify(data))
		#file.close()
		#print("Game saved")
	#else:
		#print("Failed to open save file")
		
#func loadGame(slot: int) -> Dictionary:
	#var filePath = savePath + "saveSlot" + str(slot) + ".json"
	#if not FileAccess.file_exists(filePath):
		#print("No save found in slot", slot)
		#return{}
		#
	#var file = FileAccess.open(filePath, FileAccess.READ)
	#var content = file.get_as_text()
	#file.close()
	#
	#var result = JSON.parse_string(content)
	#if typeof(result) == TYPE_DICTIONARY:
		#return result
	#else:
		#print("Failed to load save data")
		#return {}
func loadGame() -> Dictionary:
	var filePath = savePath + "save.json"
	if not FileAccess.file_exists(filePath):
		print("No save found")
		return {}
	
	var file = FileAccess.open(filePath, FileAccess.READ)
	if not file:
		print("Failed to open save file")
		return {}
	
	var content = file.get_as_text()
	file.close()
	
	var result = JSON.parse_string(content)
	if result.error == OK:
		return result.result
	else:
		print("Failed to load save data:", result.error_string)
		return {}
		
func deleteSave(slot: int) -> void:
	var filePath = savePath + "saveSlot" + str(slot) + ".json"
	if FileAccess.file_exists(filePath):
		var dir = DirAccess.open(savePath)
		#DirAccess.remove_absolute(filePath)
		#FileAccess.remove(filePath)
		if dir:
			dir.remove("saveSlot" + str(slot) + ".json")
			print("Deleted save slot", slot)
		#print("Deleted save slot", slot)

func getAvailableSaves() -> Array:
	var saves = []
	for i in range(1, saveSlotCount + 1):
		var path = savePath + "saveSlot" + str(i) + ".json"
		if FileAccess.file_exists(path):
			saves.append(i)
	return saves
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
