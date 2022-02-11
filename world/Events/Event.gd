extends Node

class_name Event

var activation_range
var occured
var input_required
var repeating
var location
var global_event_index

enum STATES {IDLE, RUNNING}
var current_state

func _ready():
	current_state = STATES.IDLE

func _process(_delta):
	if current_state == STATES.IDLE:
		if (not occured) or repeating:
			if self.global_position.distance_to(Global.player.global_position) < activation_range:
				if (not input_required) or Input.is_action_just_pressed("a"):
					# Trigger Event
					trigger_event()
					occured = true

func _init(ar = 100, o = false, ir = false, r = false, loc = null, gei = -1):
	activation_range = ar
	occured = o
	input_required = ir
	repeating = r
	location = loc
	global_event_index = gei

func trigger_event():
	Global.player.can_move = false
	current_state = STATES.RUNNING

func end_event():
	Global.player.can_move = true
	Global.events[location][global_event_index] = true
	current_state = STATES.IDLE
