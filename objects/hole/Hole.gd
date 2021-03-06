extends Sprite

class_name Hole

var dest
var active = false
var input_required = false

export(Texture) var sprite

func _ready():
	texture = sprite

func _process(_delta):
	if(self.global_position.distance_to(Global.player.global_position) < 75):
		active = true
	else:
		active = false
	if active and !input_required:
		go()

func _input(event):
	if (event.is_action_pressed("a") and active):
		go()

func _init(d, ir):
	dest = d
	input_required = ir

func go():
	Global.main.enterHole(dest)
