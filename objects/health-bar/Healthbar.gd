extends Sprite

onready var children = get_children()

const MAX_PETALS = 6
var num_petals = 0
var num_petals_lost = 0
var petals = []

func _ready():
	Global.player.connect("health_changed", self, "_on_health_changed")

func _on_health_changed(amount):
	if amount < 0:
		for _i in range(amount, 0):
			var lost_petal = children.pop_front()
			lost_petal.queue_free()

func _process(_delta):
	pass
