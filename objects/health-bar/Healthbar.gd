extends Sprite

onready var petal_scene = preload("res://objects/health-bar/Petal.tscn")

const MAX_PETALS = 6
var num_petals = 0
var petals = []

func _ready():
	var step = 360/MAX_PETALS
	for angle in range(0, 360, step):
		var petal = Global.instance_node(petal_scene, self)
		petal.rotation = deg2rad(angle)
		petals.push_back(petal)
		num_petals += 1
	Global.player.connect("health_changed", self, "_on_health_changed")

func _on_health_changed(amount):
	if amount < 0:
		for i in range(amount, 0):
			var lost_petal = petals.pop_back()
			lost_petal.animations.play("fall")

func _process(delta):
	pass