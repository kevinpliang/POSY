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
		movePlayer(Global.playerlocation)
	else:
		movePlayer(Global.LOCATIONS.GARDEN)
		
func movePlayer(dest):
	removeAllChildren($Game)
	Global.playerlocation = sceneOf[dest]
	var new_location_instance = Global.instance_node(sceneOf[dest], $Game)
	Global.player = Global.instance_node_at(Zee, new_location_instance.spawn, $Game)
	Global.instance_node_at(HealthBar, Vector2(125,125), $UI)

# Helper methods
func removeAllChildren(node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

# Music 
func playMusic(song):
	$Music.stream = song
	$Music.play()

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

var playerDest
func enterHole(dest):
	Global.player.can_move = false
	$UI/Fade.visible = true
	playerDest = dest
	$UI/Fade/Player.play("fade_in")

func _on_Player_animation_finished(anim_name):
	if anim_name == "fade_in":
		movePlayer(playerDest)
		$UI/Fade/Player.play("fade_out")
	if anim_name == "fade_out":
		$UI/Fade.visible = false
		Global.player.can_move = true
