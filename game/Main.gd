extends Node

onready var Zee = preload("res://characters/Zee.tscn")
onready var Test_stage = preload("res://world/Test_stage.tscn")
onready var Garden = preload("res://world/Garden/Garden.tscn")

onready var HealthBar = preload("res://objects/health-bar/Healthbar.tscn")

onready var Bat = preload("res://characters/enemies/Love_bat.tscn")
onready var Rat = preload("res://characters/enemies/Rat.tscn")

onready var Dialogue = preload("res://game/helper scenes/DialogueBox.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.main = self;
	# OS.window_maximized = true
	
	# Global.instance_node(Greenscreen, self);
	Global.instance_node(Garden, $Game);
	
	Global.instance_node_at(Zee, Vector2(500,500),$Game);
	Global.instance_node_at(HealthBar, Vector2(150, 150), $UI);
	Global.instance_node_at(Dialogue, Vector2(0, 0), $UI);
	# Global.instance_node_at(Bat, Vector2(500, 300), self)
	# Global.instance_node_at(Rat, Vector2(0, 500), self)
	# Global.instance_node_at(Rat, Vector2(2000, 500), self)

func _input(event):
	if (event.is_action_pressed("esc")):
		get_tree().paused = !(get_tree().paused)
		$Pause/Control.visible = !$Pause/Control.visible

func _process(_delta):
	$UI/Performance.set_text( String(Performance.get_monitor(Performance.TIME_FPS))+"FPS")
	
