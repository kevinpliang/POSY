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
		
func cutscene0():
	curr_state = STATES.CS0

func cutscene1():
	curr_state = STATES.CS1
	var dialog = Dialogic.start('Garden1', false)
	add_child(dialog)
	dialog.connect("timeline_end", self, "cutscene2")
	
func cutscene2(timeline_end):
	curr_state = STATES.CS2
	dahliaInstance.vel = Vector2(dahliaInstance.WALK_SPEED,0)
	dahliaInstance.visibilityNotifier.connect("screen_exited", self, "cutscene2end")
	
func cutscene2end():
	# goodbye Dahlia! 
	dahliaInstance.queue_free()
	curr_state = STATES.IDLE
	
	
	
