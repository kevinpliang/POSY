extends Node

class_name Location

# Music
onready var music

# States
enum STATES {IDLE, CS}
var curr_state

# Events
var events = []

# Physical objects
var entryways = []

# Global Location Identifer
var GLI

func _ready():
	pass

func _process(delta):
	pass

func _init():
	pass
