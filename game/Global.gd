extends Node

# Global instances
var main = null
var player = null

# Game state variables

# Save Variables
var savepath = "user://save.dat"
var playername = "Zee"
var playerlocation
enum LOCATIONS {GARDEN}

# Events
var events = {
	LOCATIONS.GARDEN : [true],
}

func _ready():
	pass

func _process(_delta):
	pass

# Helper functions

func instance_node(node, parent):
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

func instance_node_at(node, location, parent):
	var node_instance = node.instance()
	parent.add_child(node_instance)
	node_instance.global_position = location
	return node_instance
	
# Save functions

# Saves game to save file. Returns true if save succesful	
func saveGame() -> bool:
	var saveData = {
		"playername": playername,
		"location": playerlocation,
		"events": events,
	}
	var file = File.new()
	var error = file.open(savepath, File.WRITE)
	#var error = file.open_encrypted_with_pass(savepath, File.WRITE, "password")
	if error == OK:
		file.store_var(saveData)
		file.close()
		return true
	return false

# Loads game from save file. Returns true if load succesful	
func loadGame() -> bool:
	var file = File.new()
	if file.file_exists(savepath):
		var error = file.open(savepath, File.READ)
		#var error = file.open_encrypted_with_pass(savepath, File.READ, "password")
		if error == OK:
			var saveData = file.get_var()
			
			# load global variables from saveData
			playername = saveData["playername"]
			playerlocation = saveData["location"]	
			events = saveData["events"]
			
			file.close()
			return true
	return false
