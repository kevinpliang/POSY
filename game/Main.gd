extends Node

onready var Zee = preload("res://characters/Zee.tscn")
onready var Test_stage = preload("res://world/Test_stage.tscn")

onready var Bat = preload("res://characters/enemies/Love_bat.tscn")
onready var Rat = preload("res://characters/enemies/Rat.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.main = self;
	Global.instance_node_at(Zee, Vector2(960,100),self);
	#Global.instance_node_at(Bat, Vector2(100,300), self)
	Global.instance_node_at(Rat, Vector2(1500, 500), self)
	Global.instance_node(Test_stage, self);

func _process(delta):
	pass
