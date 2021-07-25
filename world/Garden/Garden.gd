extends Node

onready var Dahlia = preload("res://characters/Dahlia.tscn")
var dahliaInstance

# scene state
enum STATES {IDLE, CS0, CS1, CS2}
var curr_state

func _ready():
	curr_state = STATES.CS0
	dahliaInstance = Global.instance_node_at(Dahlia, Vector2(700,400), self)
	dahliaInstance.vel = Vector2(-dahliaInstance.WALK_SPEED, 0)

func _process(delta):
	if (curr_state != STATES.IDLE):
		Global.player.can_move = false
	else:
		Global.player.can_move = true
	
	if (curr_state == STATES.CS0 && dahliaInstance.global_position.x - Global.player.global_position.x < 100):
		dahliaInstance.vel = Vector2.ZERO
		cutscene1()
		
func cutscene1():
	curr_state = STATES.CS1
	var Garden1 = Dialogic.start('Garden1', false)
	add_child(Garden1)
	Garden1.connect("timeline_end", self, "showNameEntry")

func showNameEntry(timeline_end):
	$NameEntry.visible = true
	$NameEntry.grab_focus()
	
func _on_NameEntry_text_entered(new_text):
	Global.playername = new_text
	Dialogic.set_variable("playername", new_text)
	$NameEntry.visible = false
	$NameEntry.release_focus()
	var Garden2 = Dialogic.start('Garden2', false)
	add_child(Garden2)
	Garden2.connect("timeline_end", self, "cutscene2")

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
