extends Node

onready var Zee = preload("res://characters/Zee.tscn")
onready var Test_stage = preload("res://world/Test_stage.tscn")
onready var Nobel = preload("res://world/Garden/Garden.tscn")

onready var Bat = preload("res://characters/enemies/Love_bat.tscn")
onready var Rat = preload("res://characters/enemies/Rat.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.main = self;
	# OS.window_maximized = true
	
	#Global.instance_node(Test_stage, self);
	Global.instance_node(Nobel, self);
	
	Global.instance_node_at(Zee, Vector2(960,100),self);
	Global.instance_node_at(Rat, Vector2(500, 500), self)

func _process(_delta):
	pass
