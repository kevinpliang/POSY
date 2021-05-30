extends Node

onready var Zee = preload("res://characters/Zee.tscn")
onready var Test_stage = preload("res://world/Test_stage.tscn")
onready var Nobel = preload("res://world/Garden/Garden.tscn")

onready var HealthBar = preload("res://objects/health-bar/Healthbar.tscn")

onready var Bat = preload("res://characters/enemies/Love_bat.tscn")
onready var Rat = preload("res://characters/enemies/Rat.tscn")

onready var Dialogue = preload("res://game/helper scenes/DialogueBox.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.main = self;
	# OS.window_maximized = true
	
	# Global.instance_node(Test_stage, self);
	Global.instance_node(Nobel, self);
	
	Global.instance_node_at(Zee, Vector2(960,100),self);
	Global.instance_node_at(HealthBar, Vector2(150, 150), $UI);
	Global.instance_node_at(Dialogue, Vector2(0, 0), $UI);
	Global.instance_node_at(Rat, Vector2(500, 500), self)
	Global.instance_node_at(Rat, Vector2(2000, 500), self)

func _process(_delta):
	pass
