extends Button

func _ready():
	pass 

func _process(_delta):
	if (visible):
		if (is_hovered()):
			grab_focus()
		if (has_focus()):
			modulate.a = 1
		else:
			modulate.a = 0.6
			
func _on_Resume_pressed():
	Global.main.togglePause()
