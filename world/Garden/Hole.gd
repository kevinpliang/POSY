extends Sprite

var active = false

func _input(event):
	if (event.is_action_pressed("a") and active):
		Global.main.movePlayer(Global.LOCATIONS.GARDEN)

func _on_Area2D_area_entered(area):
	if (area.is_in_group("player")):
		active = true

func _on_Area2D_area_exited(area):
	if (area.is_in_group("player")):
		active = false
