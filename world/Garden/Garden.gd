extends Node

# Music
onready var brisk_start = preload("res://resources/music/brisk_start.ogg")

# Player Spawn Point
var spawn = Vector2(500,600)

onready var GLI = Global.LOCATIONS.GARDEN
onready var events_occured = Global.events[GLI]
onready var myEvents = {
	0 : $MeetingDahliaEvent
}

func _ready():
	Global.main.playMusic(brisk_start)
	Global.playerlocation = GLI
	for i in range(0,events_occured.size()):
		myEvents[i].occured = events_occured[i]
