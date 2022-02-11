extends Node

# Music
onready var brisk_start = preload("res://resources/music/brisk_start.ogg")

# Player Spawn Point
var spawn = Vector2(500,600)

onready var GLI = Global.LOCATIONS.DEPTHS
onready var events_occured = Global.events[GLI]
onready var events = {
	# 0 : $MeetingDahliaEvent
}

func _ready():
	Global.main.playMusic(brisk_start)
	Global.playerlocation = GLI
	for i in range(0,events_occured.size()):
		events[i].occured = events_occured[i]
