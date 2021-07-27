extends Node

# Preloads
onready var Zee = preload("res://characters/Zee.tscn")
onready var HealthBar = preload("res://objects/health-bar/Healthbar.tscn")
onready var SaveIcon = preload("res://objects/save-notif/SaveIcon.tscn")
onready var saveIconInstance

# Worlds
onready var Garden = preload("res://world/Garden/Garden.tscn")
onready var sceneOf = {
	Global.LOCATIONS.GARDEN: Garden,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.main = self
	#startGame()

func _process(_delta):
	$UI/Performance.set_text( String(Performance.get_monitor(Performance.TIME_FPS))+"FPS")

# Game State Stuff
func startGame():
	toggleMainMenu()
	if Global.loadGame():
		movePlayer(null, sceneOf[Global.playerlocation])
	else:
		movePlayer(null, sceneOf[Global.LOCATIONS.GARDEN])
		
func movePlayer(from, to):
	if (Global.player):
		Global.player.queue_free()
	if (Global.playerlocation):
		Global.playerlocation.queue_free()
	Global.playerlocation = to
	var new_location_instance = Global.instance_node(to, $Game)
	Global.player = Global.instance_node_at(Zee, new_location_instance.spawn, $Game)
	Global.instance_node_at(HealthBar, Vector2(125,125), $UI)

# Menu Stuff
func _input(event):
	if (event.is_action_pressed("esc")):
		if $Pause/OptionsControl.visible:
			toggleOptions()
		elif $Pause/QuitControl.visible:
			toggleQuit()
		else:
			togglePause()

func toggleMainMenu():
	$MainMenu/Control.visible = !$MainMenu/Control.visible

func togglePause():
	get_tree().paused = !(get_tree().paused)
	$Pause/Control.visible = !$Pause/Control.visible

func toggleOptions():
	$Pause/Control.visible = !$Pause/Control.visible
	$Pause/OptionsControl.visible = !$Pause/OptionsControl.visible

func toggleQuit():
	$Pause/Control.visible = !$Pause/Control.visible
	$Pause/QuitControl.visible = !$Pause/QuitControl.visible
	
func showSave():
	saveIconInstance = Global.instance_node(SaveIcon, $UI)
