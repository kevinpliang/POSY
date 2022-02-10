extends "res://world/Events/Event.gd"

onready var Dahlia = preload("res://characters/Dahlia.tscn")
var dahliaInstance

# makes it so accepting name prompt doesn't auto fill "p" in text box
var firstP = false

enum RUNNING_STATES {CS0, CS1, CS2}
var current_running_state

func _ready():
	._ready()

func _process(delta):
	._process(delta)
	if (current_state == STATES.RUNNING && current_running_state == RUNNING_STATES.CS0 && dahliaInstance.vel != Vector2.ZERO && dahliaInstance.global_position.x - Global.player.global_position.x < 100):
		dahliaInstance.vel = Vector2.ZERO
		cutscene1()

func _init().(100, false, false, false, Global.LOCATIONS.GARDEN, 0):
	pass

func trigger_event():
	dahliaInstance = Global.instance_node_at(Dahlia, Vector2(700,600), self)
	dahliaInstance.vel = Vector2(-dahliaInstance.WALK_SPEED, 0)
	current_running_state = RUNNING_STATES.CS0
	.trigger_event()
	
func end_event():
	.end_event()
	
# makes it so accepting name prompt doesn't auto fill "p" in text box
func _input(event):
	if (current_running_state == RUNNING_STATES.CS1 and !firstP and event.is_action_pressed("a") and $NameEntry.has_focus() ):
		firstP = true
		yield(get_tree().create_timer(0.001), "timeout")
		$NameEntry.clear()
		
func cutscene1():
	current_running_state = RUNNING_STATES.CS1
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
	current_running_state = RUNNING_STATES.CS2
	dahliaInstance.vel = Vector2(dahliaInstance.WALK_SPEED,0)
	dahliaInstance.visibilityNotifier.connect("screen_exited", self, "cutscene2end")
	
func cutscene2end():
	# goodbye Dahlia! 
	dahliaInstance.queue_free()
	$Tutorial.visible = true
	$Tutorial/Enter.play("enter")
	(Global.events[Global.LOCATIONS.GARDEN])[0] = false
	Global.saveGame()
	end_event()


