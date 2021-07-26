extends Node

onready var Dahlia = preload("res://characters/Dahlia.tscn")
var dahliaInstance

# scene state
enum STATES {IDLE, CS0, CS1, CS2}
var curr_state

# makes it so accepting name prompt doesn't auto fill "p" in text box
var firstP = false

# yep
var spawn = Vector2(500,500)

func _ready():
	Global.playerlocation = Global.LOCATIONS.GARDEN
	if ((Global.events[Global.LOCATIONS.GARDEN])[0]):
		curr_state = STATES.CS0
		dahliaInstance = Global.instance_node_at(Dahlia, Vector2(700,400), self)
		dahliaInstance.vel = Vector2(-dahliaInstance.WALK_SPEED, 0)
	else:
		curr_state = STATES.IDLE

func _process(delta):
	if (curr_state != STATES.IDLE):
		Global.player.can_move = false
	else:
		Global.player.can_move = true
	
	if (curr_state == STATES.CS0 && dahliaInstance.global_position.x - Global.player.global_position.x < 100):
		dahliaInstance.vel = Vector2.ZERO
		cutscene1()

# makes it so accepting name prompt doesn't auto fill "p" in text box
func _input(event):
	if (!firstP and $NameEntry.has_focus() and  event.is_action_pressed("a")):
		firstP = false
		yield(get_tree().create_timer(0.001), "timeout")
		$NameEntry.clear()		
		
func cutscene1():
	curr_state = STATES.CS1
	var Garden1 = Dialogic.start('Garden1', false)
	add_child(Garden1)
	Garden1.connect("timeline_end", self, "showNameEntry")

func showNameEntry(timeline_end):
	$NameEntry.visible = true
	$NameEntry.grab_focus()
	
func _on_NameEntry_text_entered(new_text):
	if (isValidName(new_text)):
		Global.playername = new_text
		Dialogic.set_variable("playername", new_text)
		$NameEntry.visible = false
		$NameEntry.release_focus()
		var Garden2 = Dialogic.start('Garden2', false)
		add_child(Garden2)
		Garden2.connect("timeline_end", self, "cutscene2")
	else:
		$NameEntry.clear()
		$NameEntry.placeholder_text = "Invalid Name"

# Checks if the submitted player name is valid
func isValidName(name) -> bool:
	if (name.length() < 2):
		return false
	return true

func cutscene2(timeline_end):
	curr_state = STATES.CS2
	dahliaInstance.vel = Vector2(dahliaInstance.WALK_SPEED,0)
	dahliaInstance.visibilityNotifier.connect("screen_exited", self, "cutscene2end")
	
func cutscene2end():
	# goodbye Dahlia! 
	dahliaInstance.queue_free()
	curr_state = STATES.IDLE
	$Tutorial.visible = true
	$Tutorial/Enter.play("enter")
	(Global.events[Global.LOCATIONS.GARDEN])[0] = false
	Global.saveGame()
	
